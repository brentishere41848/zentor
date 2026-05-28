# Zentor Agent Instructions

Build Zentor as a legitimate, privacy-first anti-virus client application.

Required boundaries:

- Do not implement stealth behavior, rootkit behavior, malware-like persistence, credential theft, unrelated file scanning, or hidden surveillance.
- Do not claim kernel-level or pre-execution protection unless the signed driver path is actually built, installed, running, and self-tested.
- Do not replace the Flutter client with a web dashboard, WebView, iframe, Electron, Tauri, React, Vite, or Next.js runtime UI.
- Do not add fake runtime users, fake charts, fake detections, fake scan results, or pretend protection metrics.
- Keep telemetry explicit, minimal, documented, and related to anti-virus protection events.
- Prefer deterministic rules and auditable decisions over opaque automated punishment.
- Every admin action and automated rule decision must be audit logged.

Engineering expectations:

- Keep the monorepo clean and typed.
- Runtime data must come only from local app state, local config, real API responses, selected file/app hash verification, and real errors/loading/empty states.
- Prefer small crates/modules with explicit ownership boundaries.
- Add or update tests for rules, API handlers, and SDK payload construction when behavior changes.
- Document commands and integration details in README and `docs/`.
- When platform-native APIs require real credentials, provide clear interfaces and comments rather than fake behavior.
