use std::path::{Path, PathBuf};

#[derive(Debug, Clone, Default)]
pub struct FileWalk {
    pub files: Vec<PathBuf>,
    pub folders_scanned: u64,
    pub bytes_estimated: u64,
    pub skipped_files: u64,
    pub permission_denied_count: u64,
}

pub fn collect_accessible_files(roots: &[PathBuf]) -> FileWalk {
    let mut walk = FileWalk::default();
    for root in roots {
        collect_one(root, &mut walk);
    }
    walk.files.sort_by_key(|path| priority(path));
    walk
}

fn collect_one(root: &Path, walk: &mut FileWalk) {
    if root.is_file() {
        add_file(root, walk);
        return;
    }
    if !root.exists() {
        walk.skipped_files += 1;
        return;
    }
    for entry in walkdir::WalkDir::new(root)
        .follow_links(false)
        .into_iter()
        .filter_entry(|entry| should_descend(entry.path()))
    {
        match entry {
            Ok(entry) if entry.file_type().is_dir() => walk.folders_scanned += 1,
            Ok(entry) if entry.file_type().is_file() => add_file(entry.path(), walk),
            Ok(_) => {}
            Err(error) => {
                walk.skipped_files += 1;
                if error
                    .io_error()
                    .is_some_and(|io_error| io_error.kind() == std::io::ErrorKind::PermissionDenied)
                {
                    walk.permission_denied_count += 1;
                }
            }
        }
    }
}

fn should_descend(path: &Path) -> bool {
    let Some(name) = path
        .file_name()
        .map(|value| value.to_string_lossy().to_lowercase())
    else {
        return true;
    };
    !matches!(
        name.as_str(),
        ".git"
            | ".svn"
            | ".hg"
            | "node_modules"
            | "target"
            | "build"
            | ".gradle"
            | ".dart_tool"
            | ".pub-cache"
            | "__pycache__"
            | "windowsapps"
            | "winsxs"
            | "$recycle.bin"
            | "system volume information"
    )
}

fn priority(path: &Path) -> u8 {
    let lower = path.display().to_string().to_lowercase();
    if lower.contains("download")
        || lower.contains("desktop")
        || lower.contains("temp")
        || lower.contains("startup")
        || lower.contains("autostart")
    {
        return 0;
    }
    let ext = path
        .extension()
        .map(|value| value.to_string_lossy().to_lowercase())
        .unwrap_or_default();
    if matches!(
        ext.as_str(),
        "exe"
            | "dll"
            | "scr"
            | "bat"
            | "cmd"
            | "ps1"
            | "vbs"
            | "js"
            | "jar"
            | "msi"
            | "zip"
            | "rar"
            | "7z"
            | "docm"
            | "xlsm"
    ) {
        return 1;
    }
    2
}

fn add_file(path: &Path, walk: &mut FileWalk) {
    match std::fs::metadata(path) {
        Ok(metadata) => {
            walk.bytes_estimated = walk.bytes_estimated.saturating_add(metadata.len());
            walk.files.push(path.to_path_buf());
        }
        Err(error) => {
            walk.skipped_files += 1;
            if error.kind() == std::io::ErrorKind::PermissionDenied {
                walk.permission_denied_count += 1;
            }
        }
    }
}
