use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum LocalAiVerdictLabel {
    Clean,
    LikelyClean,
    Unknown,
    Suspicious,
    ProbableMalware,
    ConfirmedMalware,
}
