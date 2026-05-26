use std::fs;
use std::path::Path;

use serde::{Deserialize, Serialize};

use super::thresholds::FEATURE_COUNT;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StaticFeatures {
    pub file_size: u64,
    pub file_extension: String,
    pub location_category: LocationCategory,
    pub double_extension: bool,
    pub embedded_urls_count: usize,
    pub embedded_ip_addresses_count: usize,
    pub suspicious_strings_count: usize,
    pub entropy: f64,
    pub packed_likely: bool,
    pub macro_or_script: bool,
}

impl StaticFeatures {
    pub fn to_feature_vector(&self, filename_risk_score: f32) -> [f32; FEATURE_COUNT] {
        let ext = self.file_extension.as_str();
        [
            ((self.file_size as f32 + 1.0).ln() / 20.0).clamp(0.0, 1.0),
            bool_feature(matches!(ext, "exe" | "dll" | "msi" | "scr" | "appimage")),
            bool_feature(matches!(ext, "ps1" | "bat" | "cmd" | "vbs" | "js" | "sh")),
            bool_feature(matches!(ext, "zip" | "rar" | "7z" | "iso")),
            bool_feature(matches!(
                self.location_category,
                LocationCategory::Downloads
            )),
            bool_feature(matches!(self.location_category, LocationCategory::Temp)),
            bool_feature(matches!(self.location_category, LocationCategory::Startup)),
            bool_feature(matches!(
                self.location_category,
                LocationCategory::ProgramFiles
            )),
            bool_feature(matches!(self.location_category, LocationCategory::System)),
            bool_feature(self.double_extension),
            (self.entropy as f32 / 8.0).clamp(0.0, 1.0),
            (self.embedded_urls_count as f32 / 10.0).clamp(0.0, 1.0),
            (self.embedded_ip_addresses_count as f32 / 10.0).clamp(0.0, 1.0),
            (self.suspicious_strings_count as f32 / 6.0).clamp(0.0, 1.0),
            bool_feature(self.packed_likely),
            bool_feature(self.macro_or_script),
            filename_risk_score.clamp(0.0, 1.0),
            0.0,
        ]
    }
}

fn bool_feature(value: bool) -> f32 {
    if value {
        1.0
    } else {
        0.0
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum LocationCategory {
    Downloads,
    Temp,
    Startup,
    System,
    ProgramFiles,
    UserProfile,
    Unknown,
}

pub fn extract_static_features(path: &Path) -> anyhow::Result<StaticFeatures> {
    let metadata = fs::metadata(path)?;
    let path_lower = path.display().to_string().to_lowercase();
    let file_name = path
        .file_name()
        .map(|name| name.to_string_lossy().to_lowercase())
        .unwrap_or_default();
    let extension = path
        .extension()
        .map(|ext| ext.to_string_lossy().to_lowercase())
        .unwrap_or_default();
    let bytes = fs::read(path).unwrap_or_default();
    let sample = if bytes.len() > 1024 * 1024 {
        &bytes[..1024 * 1024]
    } else {
        &bytes
    };
    let text = String::from_utf8_lossy(sample).to_lowercase();
    let entropy = entropy(sample);
    Ok(StaticFeatures {
        file_size: metadata.len(),
        file_extension: extension.clone(),
        location_category: location_category(&path_lower),
        double_extension: suspicious_double_extension(&file_name),
        embedded_urls_count: text.matches("http://").count() + text.matches("https://").count(),
        embedded_ip_addresses_count: count_ipv4_like(&text),
        suspicious_strings_count: count_suspicious_strings(&text),
        entropy,
        packed_likely: entropy >= 7.6,
        macro_or_script: matches!(
            extension.as_str(),
            "ps1" | "bat" | "cmd" | "vbs" | "js" | "docm" | "xlsm"
        ),
    })
}

pub fn filename_risk_score(path: &Path) -> f32 {
    let file_name = path
        .file_name()
        .map(|name| name.to_string_lossy().to_lowercase())
        .unwrap_or_default();
    let mut score: f32 = 0.0;
    if suspicious_double_extension(&file_name) {
        score += 0.45;
    }
    if looks_randomish(&file_name) {
        score += 0.20;
    }
    if file_name.contains("crack") || file_name.contains("keygen") || file_name.contains("patcher")
    {
        score += 0.25;
    }
    score.clamp(0.0, 1.0)
}

fn location_category(path_lower: &str) -> LocationCategory {
    if path_lower.contains("download") {
        LocationCategory::Downloads
    } else if path_lower.contains("\\temp\\") || path_lower.contains("/tmp/") {
        LocationCategory::Temp
    } else if path_lower.contains("startup") || path_lower.contains("autostart") {
        LocationCategory::Startup
    } else if path_lower.contains("\\windows\\") || path_lower.starts_with("/system") {
        LocationCategory::System
    } else if path_lower.contains("program files") || path_lower.starts_with("/usr") {
        LocationCategory::ProgramFiles
    } else if path_lower.contains("users") || path_lower.contains("/home/") {
        LocationCategory::UserProfile
    } else {
        LocationCategory::Unknown
    }
}

fn suspicious_double_extension(lower: &str) -> bool {
    [
        ".pdf.", ".doc.", ".docx.", ".xls.", ".xlsx.", ".jpg.", ".png.",
    ]
    .iter()
    .any(|ext| lower.contains(ext))
        && [".exe", ".scr", ".bat", ".cmd", ".ps1", ".vbs", ".js"]
            .iter()
            .any(|ext| lower.ends_with(ext))
}

fn count_suspicious_strings(text: &str) -> usize {
    [
        "frombase64string",
        "invoke-expression",
        "powershell -enc",
        "vssadmin delete shadows",
        "bcdedit /set",
        "disableantispyware",
    ]
    .iter()
    .filter(|needle| text.contains(**needle))
    .count()
}

fn count_ipv4_like(text: &str) -> usize {
    text.split_whitespace()
        .filter(|part| {
            let octets = part.trim_matches(|c: char| !c.is_ascii_digit() && c != '.');
            let values = octets.split('.').collect::<Vec<_>>();
            values.len() == 4 && values.iter().all(|value| value.parse::<u8>().is_ok())
        })
        .count()
}

fn entropy(bytes: &[u8]) -> f64 {
    if bytes.is_empty() {
        return 0.0;
    }
    let mut counts = [0usize; 256];
    for byte in bytes {
        counts[*byte as usize] += 1;
    }
    let len = bytes.len() as f64;
    counts
        .iter()
        .filter(|count| **count > 0)
        .map(|count| {
            let p = *count as f64 / len;
            -p * p.log2()
        })
        .sum()
}

fn looks_randomish(name: &str) -> bool {
    let stem = name.split('.').next().unwrap_or(name);
    if stem.len() < 8 || !stem.chars().all(|c| c.is_ascii_alphanumeric()) {
        return false;
    }
    let digits = stem.chars().filter(|c| c.is_ascii_digit()).count();
    let letters = stem.chars().filter(|c| c.is_ascii_alphabetic()).count();
    digits >= 3 && letters >= 3
}
