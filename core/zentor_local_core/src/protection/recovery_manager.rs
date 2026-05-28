use std::fs;
use std::path::{Path, PathBuf};

use anyhow::Context;
use uuid::Uuid;

pub struct RecoveryManager {
    vault: PathBuf,
}

impl RecoveryManager {
    pub fn new(vault: PathBuf) -> Self {
        Self { vault }
    }

    pub fn backup_before_change(&self, original: &Path) -> anyhow::Result<PathBuf> {
        fs::create_dir_all(&self.vault)?;
        let file_name = original
            .file_name()
            .map(|value| value.to_string_lossy().to_string())
            .unwrap_or_else(|| "file".to_string());
        let backup = self.vault.join(format!("{}-{file_name}", Uuid::new_v4()));
        fs::copy(original, &backup).with_context(|| "unable to create recovery vault copy")?;
        Ok(backup)
    }

    pub fn restore_from_vault(&self, backup: &Path, destination: &Path) -> anyhow::Result<()> {
        if let Some(parent) = destination.parent() {
            fs::create_dir_all(parent)?;
        }
        fs::copy(backup, destination).with_context(|| "unable to restore recovery vault copy")?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    #[test]
    fn recovery_manager_restores_from_test_recovery_vault() {
        let dir = tempdir().unwrap();
        let original = dir.path().join("report.docx");
        fs::write(&original, b"original").unwrap();
        let manager = RecoveryManager::new(dir.path().join("vault"));
        let backup = manager.backup_before_change(&original).unwrap();
        fs::write(&original, b"encrypted").unwrap();
        manager.restore_from_vault(&backup, &original).unwrap();
        assert_eq!(fs::read(&original).unwrap(), b"original");
    }
}
