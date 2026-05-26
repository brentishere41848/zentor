use serde::Serialize;

#[derive(Debug, Clone, Serialize)]
pub struct WatcherState {
    pub active: bool,
    pub watched_paths: Vec<String>,
}

impl WatcherState {
    pub fn stopped() -> Self {
        Self {
            active: false,
            watched_paths: Vec::new(),
        }
    }
}
