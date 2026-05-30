# Zentor Anti-Virus Status

## Current Phase

Phase 0: repository audit and publication readiness.

## Completed Work

- Zentor project structure is present with Flutter client, Rust engine/service crates, native assets, docs, tools, installer folders, and archived legacy website material.
- Active API naming has been moved toward device and security-event terminology.
- SQL migration duplicate device table/column definitions have been cleaned up.
- Project control files are present.
- Baseline repository audit report added at `docs/reports/repo-audit.md`.
- Windows driver setup scripts fail honestly when Visual Studio Build Tools/EWDK are missing.

## Blockers

- No signed Windows driver has been built, installed, run, or self-tested in this environment.
- Production ML dataset and independent anti-virus validation are not present.
- Rust, Flutter, and Dart CLIs are not installed or not on `PATH` in this local environment.

## Tests Passed

- `tools/branding/branding-check.ps1`
- `tools/security/zentor-product-copy-gate.ps1`

## Tests Failing

- `cargo test --workspace` could not run because `cargo` is not installed or not on `PATH`.
- `flutter analyze` and `flutter test` could not run because `flutter` is not installed or not on `PATH`.
- `dart test` for `packages/zentor_protocol` could not run because `dart` is not installed or not on `PATH`.
- `tools/security/zentor-false-positive-gate.ps1` fixture checks pass, but the gate cannot complete without `cargo`.
- `tools/windows/zentor-release-gate.ps1` cannot complete without toolchains and a driver self-test report.
- `core/zentor_windows_minifilter/scripts/setup-dev-env-check.ps1` and `core/zentor_windows_process_guard/scripts/setup-dev-env-check.ps1` fail because Visual Studio Build Tools/EWDK are missing.

## Current Commit

`d5c778a`

## Next Exact Task

Continue Phase 1 cleanup by removing active legacy/unrelated wording from test fixtures and replacing placeholder platform notes with honest validation interfaces.

## Final Limitations

Zentor must not claim kernel-level or pre-execution protection until the signed driver path is built, installed, running, and self-tested. No anti-virus can guarantee complete protection.
