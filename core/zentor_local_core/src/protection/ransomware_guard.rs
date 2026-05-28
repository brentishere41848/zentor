use std::path::PathBuf;

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RansomwareSignal {
    pub process_id: u32,
    pub process_path: String,
    pub affected_paths: Vec<String>,
    pub files_modified_count: u32,
    pub files_renamed_count: u32,
    pub entropy_change_score: f32,
    pub ransom_note_score: f32,
    pub backup_tamper_score: f32,
    pub time_window_seconds: u32,
    pub severity: String,
    pub confidence: String,
}

pub struct RansomwareGuard;

impl RansomwareGuard {
    pub fn evaluate(
        process_id: u32,
        process_path: impl Into<String>,
        modified_paths: &[PathBuf],
        renamed_count: u32,
        entropy_change_score: f32,
        ransom_note_score: f32,
        backup_tamper_score: f32,
        time_window_seconds: u32,
    ) -> Option<RansomwareSignal> {
        let modifications = modified_paths.len() as u32;
        let severe_file_activity =
            modifications >= 25 && time_window_seconds <= 120 && entropy_change_score >= 0.55;
        let ransom_note_activity = ransom_note_score >= 0.75 && modifications >= 10;
        let backup_tamper = backup_tamper_score >= 0.75;
        if !(severe_file_activity || ransom_note_activity || backup_tamper) {
            return None;
        }
        let confidence = if severe_file_activity && (ransom_note_activity || backup_tamper) {
            "high"
        } else {
            "medium"
        };
        Some(RansomwareSignal {
            process_id,
            process_path: process_path.into(),
            affected_paths: modified_paths
                .iter()
                .map(|path| path.display().to_string())
                .collect(),
            files_modified_count: modifications,
            files_renamed_count: renamed_count,
            entropy_change_score,
            ransom_note_score,
            backup_tamper_score,
            time_window_seconds,
            severity: "critical".to_string(),
            confidence: confidence.to_string(),
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn ransomware_mass_file_modification_triggers_guard() {
        let paths = (0..30)
            .map(|idx| PathBuf::from(format!("C:/Users/Test/Documents/file{idx}.docx")))
            .collect::<Vec<_>>();
        let signal = RansomwareGuard::evaluate(
            42,
            "C:/Users/Test/AppData/Temp/bad.exe",
            &paths,
            30,
            0.8,
            0.0,
            0.0,
            60,
        );
        assert!(signal.is_some());
    }
}
