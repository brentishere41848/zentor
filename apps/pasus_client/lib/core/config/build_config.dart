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

const pasusUpdatesRepoOwner = String.fromEnvironment(
  'PASUS_UPDATES_REPO_OWNER',
  defaultValue: 'brentishere41848',
);

const pasusUpdatesRepoName = String.fromEnvironment(
  'PASUS_UPDATES_REPO_NAME',
  defaultValue: 'pasus_anti-virus',
);

const pasusAppVersion = String.fromEnvironment(
  'PASUS_APP_VERSION',
  defaultValue: '0.1.15',
);

class BuildConfig {
  const BuildConfig({
    this.apiBaseUrl = pasusApiBaseUrl,
    this.projectId = pasusProjectId,
    this.publicGameKey = pasusPublicGameKey,
    this.updatesRepoOwner = pasusUpdatesRepoOwner,
    this.updatesRepoName = pasusUpdatesRepoName,
    this.appVersion = pasusAppVersion,
  });

  final String apiBaseUrl;
  final String projectId;
  final String publicGameKey;
  final String updatesRepoOwner;
  final String updatesRepoName;
  final String appVersion;
}
