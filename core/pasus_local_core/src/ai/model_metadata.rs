use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ModelMetadata {
    pub model_name: String,
    pub model_version: String,
    pub model_type: String,
    pub feature_schema_version: String,
    pub trained_at: DateTime<Utc>,
    pub production_ready: bool,
    pub training_dataset_name: String,
    pub training_sample_count: u64,
    pub validation_sample_count: u64,
    pub false_positive_rate: Option<f32>,
    pub precision: Option<f32>,
    pub recall: Option<f32>,
    pub thresholds: ModelThresholds,
    pub supported_categories: Vec<String>,
    pub limitations: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ModelThresholds {
    pub suspicious: f32,
    pub probable_malware: f32,
    pub confirmed_malware: f32,
}

impl Default for ModelMetadata {
    fn default() -> Self {
        Self {
            model_name: "pasus_static_malware_model".to_string(),
            model_version: "unavailable".to_string(),
            model_type: "unavailable".to_string(),
            feature_schema_version: "1.0.0".to_string(),
            trained_at: Utc::now(),
            production_ready: false,
            training_dataset_name: "none".to_string(),
            training_sample_count: 0,
            validation_sample_count: 0,
            false_positive_rate: None,
            precision: None,
            recall: None,
            thresholds: ModelThresholds {
                suspicious: 0.72,
                probable_malware: 0.90,
                confirmed_malware: 0.995,
            },
            supported_categories: vec!["unknown".to_string()],
            limitations: vec!["Model metadata unavailable.".to_string()],
        }
    }
}
