# Quarantine

When scan mode allows quarantine and Pasus finds a confirmed infected file, Pasus automatically quarantines it. Detect-only scans never quarantine or delete files.

The same quarantine store is used by manual scans and Pasus Guard. If the Guard stops a confirmed threat after launch, it moves the executable into this store and writes a JSON record with the action taken.

## Behavior

Pasus:

- Moves the file into the Pasus quarantine folder.
- Renames it to a safe random ID with a `.pasusq` extension.
- Removes executable permissions where supported.
- Stores a JSON metadata record.
- Shows a local event in the app.
- Reports detection metadata to Pasus Cloud if the cloud is online.

Pasus does not permanently delete infected files automatically.

## Storage

Default quarantine locations:

- Windows: `%ProgramData%/Pasus/Quarantine` or user app data fallback.
- macOS: `~/Library/Application Support/Pasus/Quarantine`.
- Linux: `~/.local/share/pasus/quarantine`.

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
