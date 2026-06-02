# Avorax Testing

This file documents the test and build checks used for the Avorax hardening sprint.

## Toolchain notes

On this Windows development machine, Flutter is installed at:

```text
C:\Users\Brent\develop\flutter\bin
```

From Git Bash, prefer explicit `.bat` invocations:

```bash
'/c/Users/Brent/develop/flutter/bin/flutter.bat' analyze
'/c/Users/Brent/develop/flutter/bin/flutter.bat' test
'/c/Users/Brent/develop/flutter/bin/dart.bat' test
```

## Flutter client

```bash
cd apps/zentor_client
'/c/Users/Brent/develop/flutter/bin/flutter.bat' analyze
'/c/Users/Brent/develop/flutter/bin/flutter.bat' test
'/c/Users/Brent/develop/flutter/bin/flutter.bat' build windows --debug
```

Current coverage includes API failure handling, startup smoke tests, app detection empty states, scan target planning, offline scan orchestration, stale error clearing, and local event log corruption recovery.

## Rust local core

```bash
cargo test --manifest-path core/zentor_local_core/Cargo.toml
```

Current coverage includes file walking, heuristic detection, YARA-style rule behavior, AI/model safety gates, allowlist validation, quarantine metadata/restore/delete safety, guard mode configuration, ransomware guard simulation, and scan job cancellation primitives.

## Rust guard service

```bash
cargo test --manifest-path core/zentor_guard_service/Cargo.toml
```

Current coverage includes configured guard modes, driver IPC verdict behavior, known-good/known-bad handling, lockdown behavior, and mock process monitoring.

## Rust native engine

```bash
cargo test --manifest-path core/zentor_native_engine/Cargo.toml
```

Known environment limitation: Microsoft Defender may block the native-engine test executable with Windows error 225 because antivirus test fixtures intentionally resemble malware signatures. That is an environment/security-tool block, not a successful test run. Re-run in a trusted development folder or with an explicit developer exclusion only if appropriate.

## Dart protocol package

```bash
cd packages/zentor_protocol
'/c/Users/Brent/develop/flutter/bin/dart.bat' test
```

## Release/build gates

Run these before tagging or shipping an installer when the required Windows/PowerShell environment is available:

```bash
powershell.exe -ExecutionPolicy Bypass -File tools/branding/branding-check.ps1
powershell.exe -ExecutionPolicy Bypass -File tools/security/zentor-product-copy-gate.ps1
powershell.exe -ExecutionPolicy Bypass -File tools/security/zentor-false-positive-gate.ps1
powershell.exe -ExecutionPolicy Bypass -File tools/windows/zentor-release-gate.ps1
```

Some service/driver/update gates may require elevation or a signed installed driver. If they cannot run, document the blocker in `RUN_LOG.md` and do not claim the gated capability as verified.
