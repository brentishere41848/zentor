class AppRegistryEntry {
  const AppRegistryEntry({
    required this.appId,
    required this.displayName,
    required this.processNames,
    required this.executableNames,
    this.launcherIds = const [],
    this.expectedBuildHashes = const [],
    this.allowedPathHints = const [],
    this.protectionProfile = 'standard',
  });

  final String appId;
  final String displayName;
  final List<String> processNames;
  final List<String> executableNames;
  final List<String> launcherIds;
  final List<String> expectedBuildHashes;
  final List<String> allowedPathHints;
  final String protectionProfile;
}

class AppRegistry {
  const AppRegistry();

  List<AppRegistryEntry> get entries => const [
    AppRegistryEntry(
      appId: 'zentor-example-fps',
      displayName: 'Zentor Example FPS',
      processNames: ['zentor-example-fps.exe', 'zentor-example-fps'],
      executableNames: ['zentor-example-fps.exe', 'zentor-example-fps'],
      launcherIds: ['zentor-example-fps'],
      allowedPathHints: ['ZentorExampleFPS'],
      protectionProfile: 'competitive',
    ),
    AppRegistryEntry(
      appId: 'zentor-example-arena',
      displayName: 'Zentor Example Arena',
      processNames: ['zentor-arena.exe', 'zentor-arena'],
      executableNames: ['zentor-arena.exe', 'zentor-arena'],
      launcherIds: ['zentor-arena'],
      allowedPathHints: ['ZentorArena'],
      protectionProfile: 'standard',
    ),
  ];
}
