# Pasus Client UI

Pasus is a native Flutter Material 3 app. The runtime UI is not a website, browser, WebView, iframe, or embedded dashboard.

## First Screen

The app opens to Home, not an API setup form. Home shows:

- Cloud status pill.
- Protection status pill.
- Run Quick Scan action.
- Run Full Scan action.
- Enable Protection action.
- Compact cards for Real-time protection, Malware engine, Last scan, Quarantine, Updates, and optional Gaming Protection.
- Updates are based on real GitHub Release metadata. Pasus shows update available, up to date, checking, or check failed, and never installs silently.
- Recent activity from real local events only.

If Pasus Cloud is unavailable, the UI shows `Cloud Offline` without a red blocking setup form.

## Navigation

Desktop uses a left sidebar:

- Home
- Scan
- Protection
- Quarantine
- Allowlist
- Device
- Security Events
- Settings
- Gaming Protection

Mobile uses bottom navigation:

- Home
- Scan
- Quarantine
- Settings
- Gaming

## Empty States

Production runtime must never show fake users, fake bans, fake detections, fake games, fake charts, or fake scan results. Empty states are explicit:

- No scan results.
- No threats found.
- No quarantined files.
- No activity yet.
- Update check failed.

Gaming Protection is optional and has its own empty states. A missing game must not block antivirus protection.
