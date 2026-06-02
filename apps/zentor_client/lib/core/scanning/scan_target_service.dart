import 'dart:io';

enum ScanPlatform { windows, macos, linux, other }

class ScanTargetService {
  const ScanTargetService();

  List<String> quickScanTargets({
    Map<String, String>? environment,
    ScanPlatform? platform,
  }) {
    final env = environment ?? Platform.environment;
    final activePlatform = platform ?? _currentPlatform();
    final home = env['HOME'] ?? env['USERPROFILE'];
    final targets = <String>{};
    void addIfPresent(String? path) {
      if (path == null || path.trim().isEmpty) return;
      if (FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound) {
        targets.add(path);
      }
    }

    if (home != null) {
      addIfPresent(_join(home, 'Downloads', activePlatform));
      addIfPresent(_join(home, 'Desktop', activePlatform));
    }

    switch (activePlatform) {
      case ScanPlatform.windows:
        addIfPresent(env['TEMP']);
        addIfPresent(env['TMP']);
        final appData = env['APPDATA'];
        addIfPresent(
          appData == null
              ? null
              : _join(
                  appData,
                  r'Microsoft\Windows\Start Menu\Programs\Startup',
                  activePlatform,
                ),
        );
        final localAppData = env['LOCALAPPDATA'];
        addIfPresent(
          localAppData == null
              ? null
              : _join(localAppData, 'Temp', activePlatform),
        );
      case ScanPlatform.macos:
        addIfPresent('/tmp');
        addIfPresent(
          home == null
              ? null
              : _join(home, 'Library/LaunchAgents', activePlatform),
        );
        addIfPresent('/Library/LaunchAgents');
      case ScanPlatform.linux:
        addIfPresent('/tmp');
        addIfPresent(
          home == null
              ? null
              : _join(home, '.config/autostart', activePlatform),
        );
        addIfPresent(
          home == null ? null : _join(home, '.local/bin', activePlatform),
        );
      case ScanPlatform.other:
        addIfPresent(env['TMPDIR']);
    }
    return targets.toList()..sort();
  }

  List<String> fullScanRoots({
    Map<String, String>? environment,
    ScanPlatform? platform,
  }) {
    final env = environment ?? Platform.environment;
    final activePlatform = platform ?? _currentPlatform();
    switch (activePlatform) {
      case ScanPlatform.windows:
        final roots = <String>{};
        for (var code = 'A'.codeUnitAt(0); code <= 'Z'.codeUnitAt(0); code++) {
          final root = '${String.fromCharCode(code)}:\\';
          if (Directory(root).existsSync()) roots.add(root);
        }
        return roots.toList()..sort();
      case ScanPlatform.macos:
        final home = env['HOME'];
        return [
          if (home != null && Directory(home).existsSync()) home,
          if (Directory('/Applications').existsSync()) '/Applications',
          if (Directory('/Users').existsSync()) '/Users',
        ];
      case ScanPlatform.linux:
        final home = env['HOME'];
        return [
          if (home != null && Directory(home).existsSync()) home,
          if (Directory('/opt').existsSync()) '/opt',
          if (Directory('/usr/local').existsSync()) '/usr/local',
        ];
      case ScanPlatform.other:
        final home = env['HOME'] ?? env['USERPROFILE'];
        return [if (home != null && Directory(home).existsSync()) home];
    }
  }

  ScanPlatform _currentPlatform() {
    if (Platform.isWindows) return ScanPlatform.windows;
    if (Platform.isMacOS) return ScanPlatform.macos;
    if (Platform.isLinux) return ScanPlatform.linux;
    return ScanPlatform.other;
  }

  String _join(String base, String child, ScanPlatform platform) {
    final separator = _separatorFor(platform);
    final normalizedChild = child.replaceAll(RegExp(r'[/\\]+'), separator);
    return base.endsWith('/') || base.endsWith('\\')
        ? '$base$normalizedChild'
        : '$base$separator$normalizedChild';
  }

  String _separatorFor(ScanPlatform platform) {
    return platform == ScanPlatform.windows ? r'\' : '/';
  }
}
