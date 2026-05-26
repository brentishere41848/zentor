use super::feature_extractor::StaticFeatures;

pub fn explain_static_features(features: &StaticFeatures) -> Vec<String> {
    let mut reasons = Vec::new();
    if features.double_extension {
        reasons.push("Filename uses a document-like double extension.".to_string());
    }
    if features.packed_likely {
        reasons.push("File has high entropy that may indicate packing.".to_string());
    }
    if features.suspicious_strings_count > 0 {
        reasons.push(
            "Static strings include suspicious script or system-tampering patterns.".to_string(),
        );
    }
    if features.embedded_urls_count > 3 || features.embedded_ip_addresses_count > 2 {
        reasons.push("File contains multiple embedded network indicators.".to_string());
    }
    reasons
}
