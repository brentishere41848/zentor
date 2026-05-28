import 'dart:io';

import 'package:zentor_protocol/zentor_protocol.dart';

import 'app_registry.dart';

class AppDetector {
  const AppDetector([this._registry = const AppRegistry()]);

  final AppRegistry _registry;

  Future<List<DetectedApp>> detect() async {
    final found = <DetectedApp>[];
    found.addAll(await _detectRunningProcesses());
    found.addAll(await _detectKnownInstallPaths());
    return _dedupe(found);
  }

  Future<List<DetectedApp>> _detectRunningProcesses() async {
    final names = await _runningProcessNames();
    if (names.isEmpty) return const [];
    final detected = <DetectedApp>[];
    for (final entry in _registry.entries) {
      final running = entry.processNames.any(
        (process) => names.contains(process.toLowerCase()),
      );
      if (running) {
        detected.add(
          DetectedApp(
            appId: entry.appId,
            displayName: entry.displayName,
            path: 'Running process',
            source: 'Running Process',
            protectionProfile: entry.protectionProfile,
          ),
        );
      }
    }
    return detected;
  }

  Future<List<String>> _runningProcessNames() async {
    try {
      if (Platform.isWindows) {
        final result = await Process.run('tasklist', ['/fo', 'csv', '/nh']);
        if (result.exitCode != 0) return const [];
        return '${result.stdout}'
            .split('\n')
            .map((line) => line.split(',').first.replaceAll('"', '').trim())
            .where((name) => name.isNotEmpty)
            .map((name) => name.toLowerCase())
            .toList();
      }
      if (Platform.isLinux || Platform.isMacOS) {
        final result = await Process.run('ps', ['-axo', 'comm=']);
        if (result.exitCode != 0) return const [];
        return '${result.stdout}'
            .split('\n')
            .map((line) => line.trim().split(Platform.pathSeparator).last)
            .where((name) => name.isNotEmpty)
            .map((name) => name.toLowerCase())
            .toList();
      }
    } on Object {
      return const [];
    }
    return const [];
  }

  Future<List<DetectedApp>> _detectKnownInstallPaths() async {
    final detected = <DetectedApp>[];
    for (final root in _knownRoots()) {
      final directory = Directory(root);
      if (!await directory.exists()) continue;
      for (final entry in _registry.entries) {
        for (final hint in entry.allowedPathHints) {
          final candidateDir = Directory(_join(root, hint));
          if (!await candidateDir.exists()) continue;
          final executable = await _firstExistingExecutable(
            candidateDir.path,
            entry.executableNames,
          );
          detected.add(
            DetectedApp(
              appId: entry.appId,
              displayName: entry.displayName,
              path: executable ?? candidateDir.path,
              source: _sourceForRoot(root),
              protectionProfile: entry.protectionProfile,
            ),
          );
        }
      }
    }
    return detected;
  }

  List<String> _knownRoots() {
    if (Platform.isWindows) {
      final programFiles = Platform.environment['ProgramFiles'];
      final programFilesX86 = Platform.environment['ProgramFiles(x86)'];
      return [
        if (programFiles != null) '$programFiles\\Steam\\steamapps\\common',
        if (programFilesX86 != null)
          '$programFilesX86\\Steam\\steamapps\\common',
        if (programFiles != null) '$programFiles\\Epic Apps',
        if (programFilesX86 != null) '$programFilesX86\\GOG Galaxy\\Apps',
      ];
    }
    if (Platform.isMacOS) {
      return ['/Applications', '${Platform.environment['HOME']}/Applications'];
    }
    if (Platform.isLinux) {
      final home = Platform.environment['HOME'];
      return [
        if (home != null) '$home/.steam/steam/steamapps/common',
        if (home != null) '$home/.local/share/Steam/steamapps/common',
        if (home != null) '$home/Apps',
        '/usr/local/apps',
      ];
    }
    return const [];
  }

  Future<String?> _firstExistingExecutable(
    String root,
    List<String> executableNames,
  ) async {
    for (final executableName in executableNames) {
      final path = _join(root, executableName);
      if (await File(path).exists()) return path;
    }
    return null;
  }

  List<DetectedApp> _dedupe(List<DetectedApp> apps) {
    final seen = <String>{};
    final unique = <DetectedApp>[];
    for (final app in apps) {
      final key = '${app.appId}:${app.path}';
      if (seen.add(key)) unique.add(app);
    }
    return unique;
  }

  String _sourceForRoot(String root) {
    final lower = root.toLowerCase();
    if (lower.contains('steam')) return 'Steam';
    if (lower.contains('epic')) return 'Epic';
    if (lower.contains('gog')) return 'GOG';
    return 'Known Location';
  }

  String _join(String a, String b) {
    final separator = Platform.pathSeparator;
    return a.endsWith(separator) ? '$a$b' : '$a$separator$b';
  }
}
