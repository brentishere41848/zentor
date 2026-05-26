use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub enum ScanStatus {
    Clean,
    Infected,
    Error,
    EngineUnavailable,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScanResult {
    pub status: ScanStatus,
    pub scanned_path: String,
    pub sha256: String,
    pub engine: String,
    pub signature_name: Option<String>,
    pub threat_name: Option<String>,
    pub scanned_at: DateTime<Utc>,
    pub duration_ms: u128,
    pub raw_engine_summary: Option<String>,
}
