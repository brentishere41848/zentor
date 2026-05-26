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

class BuildConfig {
  const BuildConfig({
    this.apiBaseUrl = pasusApiBaseUrl,
    this.projectId = pasusProjectId,
    this.publicGameKey = pasusPublicGameKey,
  });

  final String apiBaseUrl;
  final String projectId;
  final String publicGameKey;
}
