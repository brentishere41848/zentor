use std::collections::{BTreeSet, HashMap};
use std::path::PathBuf;
use std::time::{Duration, Instant};

use super::file_activity::FileActivityEvent;
use super::ransomware_guard::{BehaviorDecision, RansomwareGuard};
use crate::verdict::risk_fusion::Evidence;

#[derive(Debug, Clone)]
struct ProcessWindow {
    last_seen: Instant,
    files_modified: u32,
    files_renamed: u32,
    entropy_increases: u32,
    ransom_note_created: bool,
    backup_tamper_attempt: bool,
    affected_paths: BTreeSet<PathBuf>,
}

impl ProcessWindow {
    fn new(now: Instant) -> Self {
        Self {
            last_seen: now,
            files_modified: 0,
            files_renamed: 0,
            entropy_increases: 0,
            ransom_note_created: false,
            backup_tamper_attempt: false,
            affected_paths: BTreeSet::new(),
        }
    }

    fn apply(&mut self, now: Instant, event: &FileActivityEvent) {
        self.last_seen = now;
        self.files_modified = self
            .files_modified
            .saturating_add(event.files_modified_count);
        self.files_renamed = self.files_renamed.saturating_add(event.files_renamed_count);
        self.entropy_increases = self
            .entropy_increases
            .saturating_add(event.entropy_increase_count);
        self.ransom_note_created |= event.ransom_note_created;
        self.backup_tamper_attempt |= event.backup_tamper_attempt;
        self.affected_paths
            .extend(event.affected_paths.iter().cloned());
    }

    fn to_event(&self, process_id: u32, process_path: PathBuf) -> FileActivityEvent {
        FileActivityEvent {
            process_id,
            process_path,
            affected_paths: self.affected_paths.iter().cloned().collect(),
            files_modified_count: self.files_modified,
            files_renamed_count: self.files_renamed,
            entropy_increase_count: self.entropy_increases,
            ransom_note_created: self.ransom_note_created,
            backup_tamper_attempt: self.backup_tamper_attempt,
        }
    }
}

#[derive(Debug)]
pub struct RansomwareActivityWindow {
    retention: Duration,
    windows: HashMap<u32, ProcessWindow>,
}

impl Default for RansomwareActivityWindow {
    fn default() -> Self {
        Self::new(Duration::from_secs(90))
    }
}

impl RansomwareActivityWindow {
    pub fn new(retention: Duration) -> Self {
        Self {
            retention,
            windows: HashMap::new(),
        }
    }

    pub fn observe(&mut self, event: FileActivityEvent) -> (BehaviorDecision, Option<Evidence>) {
        let now = Instant::now();
        self.prune(now);
        let process_path = event.process_path.clone();
        let window = self
            .windows
            .entry(event.process_id)
            .or_insert_with(|| ProcessWindow::new(now));
        window.apply(now, &event);
        let aggregate = window.to_event(event.process_id, process_path);
        RansomwareGuard::analyze(&aggregate)
    }

    pub fn tracked_process_count(&self) -> usize {
        self.windows.len()
    }

    fn prune(&mut self, now: Instant) {
        let retention = self.retention;
        self.windows
            .retain(|_, window| now.duration_since(window.last_seen) <= retention);
    }
}
