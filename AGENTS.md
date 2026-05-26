# Pasus Agent Instructions

Build Pasus as a legitimate, privacy-first anti-cheat client application.

Required boundaries:

- Do not implement stealth behavior, rootkit behavior, malware-like persistence, credential theft, unrelated file scanning, or hidden surveillance.
- Do not build a kernel driver in v1.
- Do not replace the Flutter client with a web dashboard, WebView, iframe, Electron, Tauri, React, Vite, or Next.js runtime UI.
- Do not add fake runtime users, bans, charts, active sessions, or pretend protection metrics.
- Keep telemetry explicit, minimal, documented, and related to protecting the configured game.
- Prefer deterministic rules and auditable decisions over opaque automated punishment.
- Every admin action and automated rule decision must be audit logged.

Engineering expectations:

- Keep the monorepo clean and typed.
- Runtime data must come only from local app state, local config, real API responses, selected game hash verification, and real errors/loading/empty states.
- Prefer small crates/modules with explicit ownership boundaries.
- Add or update tests for rules, API handlers, and SDK payload construction when behavior changes.
- Document commands and integration details in README and `docs/`.
- When platform-native APIs require real credentials, provide clear interfaces and comments rather than fake behavior.
