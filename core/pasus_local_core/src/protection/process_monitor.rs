pub struct ProcessMonitor;

impl ProcessMonitor {
    pub fn capability() -> &'static str {
        if cfg!(windows) {
            "userModePolling"
        } else if cfg!(target_os = "macos") {
            "endpointSecurityWhenEntitled"
        } else if cfg!(target_os = "linux") {
            "fanotifyOrInotifyWhenAvailable"
        } else {
            "unavailable"
        }
    }
}
