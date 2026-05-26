use std::collections::HashSet;
use std::fs;
use std::io::{self, BufRead};
use std::path::{Path, PathBuf};
use std::process::Command;

use anyhow::Context;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use uuid::Uuid;

#[derive(Debug, Deserialize)]
struct GuardCommand {
    command: String,
    process_id: Option<u32>,
    process_path: Option<String>,
    known_malicious_hashes: Option<Vec<String>>,
}

#[derive(Debug, Serialize)]
struct GuardEvent {
    ok: bool,
    action: String,
    message: String,
    process_id: Option<u32>,
    process_path: Option<String>,
    quarantine_path: Option<String>,
    created_at: DateTime<Utc>,
}

fn main() -> anyhow::Result<()> {
    let stdin = io::stdin();
    for line in stdin.lock().lines() {
        let line = line?;
        if line.trim().is_empty() {
            continue;
        }
        let command: GuardCommand = serde_json::from_str(&line)?;
        let response = handle(command);
        println!("{}", serde_json::to_string(&response)?);
    }
    Ok(())
}

fn handle(command: GuardCommand) -> GuardEvent {
    match command.command.as_str() {
        "health" => GuardEvent {
            ok: true,
            action: "health".to_string(),
            message: "Pasus Guard Service ready for user-mode post-launch protection.".to_string(),
            process_id: None,
            process_path: None,
            quarantine_path: None,
            created_at: Utc::now(),
        },
        "process_started" => {
            let Some(path) = command.process_path else {
                return error("process_path is required");
            };
            let pid = command.process_id;
            let malicious = command
                .known_malicious_hashes
                .unwrap_or_default()
                .into_iter()
                .collect::<HashSet<_>>();
            match handle_process_started(pid, Path::new(&path), &malicious) {
                Ok(event) => event,
                Err(error) => error_event(pid, Some(path), error.to_string()),
            }
        }
        _ => error("unknown command"),
    }
}

fn handle_process_started(
    process_id: Option<u32>,
    process_path: &Path,
    known_malicious_hashes: &HashSet<String>,
) -> anyhow::Result<GuardEvent> {
    let hash = sha256_file(process_path)?;
    if !known_malicious_hashes.contains(&hash) {
        return Ok(GuardEvent {
            ok: true,
            action: "monitored".to_string(),
            message: "Process monitored. No confirmed local threat hash matched.".to_string(),
            process_id,
            process_path: Some(process_path.display().to_string()),
            quarantine_path: None,
            created_at: Utc::now(),
        });
    }

    if let Some(pid) = process_id {
        stop_process(pid);
    }
    let quarantine_path = quarantine_file(process_path)
        .with_context(|| "known malicious process was stopped but quarantine failed")?;
    Ok(GuardEvent {
        ok: true,
        action: "stoppedAndQuarantined".to_string(),
        message: "Pasus stopped the process and moved the file to quarantine.".to_string(),
        process_id,
        process_path: Some(process_path.display().to_string()),
        quarantine_path: Some(quarantine_path.display().to_string()),
        created_at: Utc::now(),
    })
}

fn stop_process(process_id: u32) {
    #[cfg(windows)]
    {
        let _ = Command::new("taskkill")
            .args(["/PID", &process_id.to_string(), "/F"])
            .output();
    }
    #[cfg(not(windows))]
    {
        let _ = Command::new("kill")
            .args(["-TERM", &process_id.to_string()])
            .output();
    }
}

fn quarantine_file(path: &Path) -> anyhow::Result<PathBuf> {
    let base = quarantine_base();
    fs::create_dir_all(&base)?;
    let destination = base.join(format!("{}.pasusq", Uuid::new_v4()));
    fs::rename(path, &destination)?;
    Ok(destination)
}

fn quarantine_base() -> PathBuf {
    #[cfg(windows)]
    {
        if let Ok(program_data) = std::env::var("PROGRAMDATA") {
            return PathBuf::from(program_data)
                .join("Pasus")
                .join("GuardQuarantine");
        }
    }
    if let Ok(home) = std::env::var("HOME") {
        return PathBuf::from(home).join(".local/share/pasus/guard-quarantine");
    }
    PathBuf::from(".pasus/guard-quarantine")
}

fn sha256_file(path: &Path) -> anyhow::Result<String> {
    let bytes = fs::read(path)?;
    let mut hasher = Sha256::new();
    hasher.update(bytes);
    Ok(format!("{:x}", hasher.finalize()))
}

fn error(message: &str) -> GuardEvent {
    error_event(None, None, message.to_string())
}

fn error_event(
    process_id: Option<u32>,
    process_path: Option<String>,
    message: String,
) -> GuardEvent {
    GuardEvent {
        ok: false,
        action: "error".to_string(),
        message,
        process_id,
        process_path,
        quarantine_path: None,
        created_at: Utc::now(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    #[test]
    fn mock_process_start_without_known_hash_is_monitored() {
        let dir = tempdir().unwrap();
        let file = dir.path().join("tool.exe");
        fs::write(&file, b"developer tool").unwrap();
        let result = handle_process_started(None, &file, &HashSet::new()).unwrap();
        assert_eq!(result.action, "monitored");
        assert!(file.exists());
    }

    #[test]
    fn known_malicious_hash_is_quarantined() {
        let dir = tempdir().unwrap();
        let file = dir.path().join("bad.exe");
        fs::write(&file, b"known bad fixture").unwrap();
        let hash = sha256_file(&file).unwrap();
        let result = handle_process_started(None, &file, &HashSet::from([hash])).unwrap();
        assert_eq!(result.action, "stoppedAndQuarantined");
        assert!(!file.exists());
        assert!(Path::new(result.quarantine_path.as_ref().unwrap()).exists());
    }
}
