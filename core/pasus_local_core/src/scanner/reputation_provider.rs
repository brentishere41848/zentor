use std::path::Path;

use super::ThreatResult;

pub struct ReputationProvider;

impl ReputationProvider {
    pub fn inspect_file(&self, _path: &Path) -> Option<ThreatResult> {
        None
    }

    pub fn status(&self) -> &'static str {
        "unavailable"
    }
}
