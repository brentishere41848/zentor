const zentorApiBaseUrl = String.fromEnvironment(
  'ZENTOR_API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8000',
);

const zentorProjectId = String.fromEnvironment(
  'ZENTOR_PROJECT_ID',
  defaultValue: 'zentor-default',
);

const zentorPublicClientKey = String.fromEnvironment(
  'ZENTOR_PUBLIC_CLIENT_KEY',
  defaultValue: 'zentor-public-client',
);

const zentorUpdatesRepoOwner = String.fromEnvironment(
  'ZENTOR_UPDATES_REPO_OWNER',
  defaultValue: 'brentishere41848',
);

const zentorUpdatesRepoName = String.fromEnvironment(
  'ZENTOR_UPDATES_REPO_NAME',
  defaultValue: 'zentor_anti-virus',
);

const zentorAppVersion = String.fromEnvironment(
  'ZENTOR_APP_VERSION',
  defaultValue: '0.1.15',
);

class BuildConfig {
  const BuildConfig({
    this.apiBaseUrl = zentorApiBaseUrl,
    this.projectId = zentorProjectId,
    this.publicClientKey = zentorPublicClientKey,
    this.updatesRepoOwner = zentorUpdatesRepoOwner,
    this.updatesRepoName = zentorUpdatesRepoName,
    this.appVersion = zentorAppVersion,
  });

  final String apiBaseUrl;
  final String projectId;
  final String publicClientKey;
  final String updatesRepoOwner;
  final String updatesRepoName;
  final String appVersion;
}
