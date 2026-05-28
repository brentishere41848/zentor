# Quarantine

When scan mode allows quarantine and Zentor finds a confirmed infected file, Zentor automatically quarantines it. Detect-only scans never quarantine or delete files.

The same quarantine store is used by manual scans and Zentor Guard. If the Guard stops a confirmed threat after launch, it moves the executable into this store and writes a JSON record with the action taken.

## Behavior

Zentor:

- Moves the file into the Zentor quarantine folder.
- Renames it to a safe random ID with a `.zentorq` extension.
- Removes executable permissions where supported.
- Stores a JSON metadata record.
- Shows a local event in the app.
- Reports detection metadata to Zentor Cloud if the cloud is online.

Zentor does not permanently delete infected files automatically.

## Storage

Default quarantine locations:

- Windows: `%ProgramData%/Zentor/Quarantine` or user app data fallback.
- macOS: `~/Library/Application Support/Zentor/Quarantine`.
- Linux: `~/.local/share/zentor/quarantine`.

## Metadata

Each record includes:

- `quarantine_id`
- `original_path`
- `quarantine_path`
- `sha256`
- `file_size`
- `detection_name`
- `engine`
- `quarantined_at`
- `status`
- optional `user_note`

## Restore, Delete, And Allowlist

Restoring requires explicit confirmation. If a restored file is still detected, the UI must warn the user. Deleting permanently is always a user action.

Users can also keep a file quarantined, restore/keep it, delete it permanently, or add it to the allowlist. Allowlisted files are skipped from automatic quarantine but still produce visible local events when relevant.
