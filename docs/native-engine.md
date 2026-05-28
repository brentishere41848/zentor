# Zentor Native Engine

Zentor Native Engine (ZNE) is the primary offline anti-malware engine. It does not require ClamAV, YARA, cloud access, an account, or internet connectivity to scan files.

ZNE v1 includes:

- Zentor native signatures (`.zsig`)
- Zentor native rules (`.zrule`)
- Static analyzers for file type, strings, entropy, PE metadata, scripts, and ZIP archives
- Conservative heuristic scoring
- Pure Rust native ML model runtime (`.zmodel`)
- Trust stores for known-good, known-bad test hashes, allowlist, and false-positive controls
- Risk fusion and action policy
- Quarantine integration
- Signature pack compilation, metadata emission, and runtime pack hash verification
- Guard Service verdict integration with ZNE as the default decision source
- A stateful ransomware activity window that accumulates file activity by process before deciding whether to warn or stop

Compatibility engines such as ClamAV and YARA are optional compatibility paths only. They are disabled by default and are not required for Quick Scan, Full Scan, Custom Scan, EICAR detection, quarantine, or Guard verdicts.

ZNE never executes suspicious files, detonates samples, uploads files, or disables other security software.

## Signature Pack Compiler

The `zentor-signature-compiler` binary compiles Zentor native signatures into `.zsig` packs and writes metadata with `pack_sha256`, signature counts, broad signature counts, and confirmed signature counts. Runtime loading validates the pack format and verifies the canonical pack hash when the hash is present.
