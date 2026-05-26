class GameRegistryEntry {
  const GameRegistryEntry({
    required this.gameId,
    required this.displayName,
    required this.processNames,
    required this.executableNames,
    this.launcherIds = const [],
    this.expectedBuildHashes = const [],
    this.allowedPathHints = const [],
    this.protectionProfile = 'standard',
  });

  final String gameId;
  final String displayName;
  final List<String> processNames;
  final List<String> executableNames;
  final List<String> launcherIds;
  final List<String> expectedBuildHashes;
  final List<String> allowedPathHints;
  final String protectionProfile;
}

class GameRegistry {
  const GameRegistry();

  List<GameRegistryEntry> get entries => const [
    GameRegistryEntry(
      gameId: 'pasus-example-fps',
      displayName: 'Pasus Example FPS',
      processNames: ['pasus-example-fps.exe', 'pasus-example-fps'],
      executableNames: ['pasus-example-fps.exe', 'pasus-example-fps'],
      launcherIds: ['pasus-example-fps'],
      allowedPathHints: ['PasusExampleFPS'],
      protectionProfile: 'competitive',
    ),
    GameRegistryEntry(
      gameId: 'pasus-example-arena',
      displayName: 'Pasus Example Arena',
      processNames: ['pasus-arena.exe', 'pasus-arena'],
      executableNames: ['pasus-arena.exe', 'pasus-arena'],
      launcherIds: ['pasus-arena'],
      allowedPathHints: ['PasusArena'],
      protectionProfile: 'standard',
    ),
  ];
}
