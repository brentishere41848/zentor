# Pasus Native Engine

Pasus Native Engine (PNE) is the primary offline anti-malware engine. It does not require ClamAV, YARA, cloud access, an account, or internet connectivity to scan files.

PNE v1 includes:

- Pasus native signatures (`.psig`)
- Pasus native rules (`.prule`)
- Static analyzers for file type, strings, entropy, PE metadata, scripts, and ZIP archives
- Conservative heuristic scoring
- Pure Rust native ML model runtime (`.pmodel`)
- Trust stores for known-good, known-bad test hashes, allowlist, and false-positive controls
- Risk fusion and action policy
- Quarantine integration
- Signature pack compilation, metadata emission, and runtime pack hash verification
- Guard Service verdict integration with PNE as the default decision source
- A stateful ransomware activity window that accumulates file activity by process before deciding whether to warn or stop

Compatibility engines such as ClamAV and YARA are optional compatibility paths only. They are disabled by default and are not required for Quick Scan, Full Scan, Custom Scan, EICAR detection, quarantine, or Guard verdicts.

PNE never executes suspicious files, detonates samples, uploads files, or disables other security software.

## Signature Pack Compiler

The `pasus-signature-compiler` binary compiles Pasus native signatures into `.psig` packs and writes metadata with `pack_sha256`, signature counts, broad signature counts, and confirmed signature counts. Runtime loading validates the pack format and verifies the canonical pack hash when the hash is present.
