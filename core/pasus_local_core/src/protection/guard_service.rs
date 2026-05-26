use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub enum GuardMode {
    Off,
    MonitorOnly,
    BlockConfirmedThreats,
    Aggressive,
}

impl Default for GuardMode {
    fn default() -> Self {
        Self::BlockConfirmedThreats
    }
}

#[derive(Default)]
pub struct GuardService {
    mode: GuardMode,
}

impl GuardService {
    pub fn status(&self) -> &'static str {
        match self.mode {
            GuardMode::Off => "off",
            GuardMode::MonitorOnly => "monitorOnly",
            GuardMode::BlockConfirmedThreats => "blockConfirmedThreats",
            GuardMode::Aggressive => "aggressive",
        }
    }
}
