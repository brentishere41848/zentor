use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

use super::NativeSignature;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SignaturePack {
    pub format: String,
    pub version: String,
    #[serde(default)]
    pub compiler_version: Option<String>,
    #[serde(default)]
    pub created_at: Option<DateTime<Utc>>,
    #[serde(default)]
    pub pack_sha256: Option<String>,
    pub signatures: Vec<NativeSignature>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SignaturePackMetadata {
    pub format: String,
    pub version: String,
    pub compiler_version: String,
    pub signature_count: usize,
    pub pack_sha256: String,
    pub created_at: DateTime<Utc>,
    pub broad_signature_count: usize,
    pub confirmed_signature_count: usize,
}
