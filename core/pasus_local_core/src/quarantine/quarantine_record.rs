use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub enum QuarantineStatus {
    Quarantined,
    Restored,
    Deleted,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct QuarantineRecord {
    pub quarantine_id: String,
    pub original_path: String,
    pub quarantine_path: String,
    pub sha256: String,
    pub file_size: u64,
    pub detection_name: String,
    pub engine: String,
    pub quarantined_at: DateTime<Utc>,
    pub status: QuarantineStatus,
    pub user_note: Option<String>,
}
