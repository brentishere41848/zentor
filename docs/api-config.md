# API Configuration

Pasus uses build-time Pasus Cloud configuration for optional cloud features. Local scanning does not require this configuration.

```dart
const pasusApiBaseUrl = String.fromEnvironment(
  'PASUS_API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8000',
);

const pasusProjectId = String.fromEnvironment(
  'PASUS_PROJECT_ID',
  defaultValue: 'pasus-default',
);

const pasusPublicGameKey = String.fromEnvironment(
  'PASUS_PUBLIC_GAME_KEY',
  defaultValue: 'pasus-public-client',
);
```

Run with custom values:

```powershell
flutter run -d windows `
  --dart-define=PASUS_API_BASE_URL=https://YOUR_API_HERE `
  --dart-define=PASUS_PROJECT_ID=YOUR_PROJECT_ID `
  --dart-define=PASUS_PUBLIC_GAME_KEY=YOUR_PUBLIC_GAME_KEY
```

The app does not require a cloud health check before scanning. Cloud checks are user-initiated from settings or future cloud update/reporting flows.

- Success shows `Cloud: Online`.
- Failure shows `Cloud: Offline`.
- Disabled shows `Cloud: Disabled`.
- Failure does not block local scanning, quarantine, or protection controls.

Manual editing is hidden in `Settings > Advanced > Developer options`.
