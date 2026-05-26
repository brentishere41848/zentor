import 'dart:io';

import 'package:pasus_protocol/pasus_protocol.dart';

import 'game_registry.dart';

class GameDetector {
  const GameDetector([this._registry = const GameRegistry()]);

  final GameRegistry _registry;

  Future<List<DetectedGame>> detect() async {
    final found = <DetectedGame>[];
    found.addAll(await _detectRunningProcesses());
    found.addAll(await _detectKnownInstallPaths());
    return _dedupe(found);
  }

  Future<List<DetectedGame>> _detectRunningProcesses() async {
    final names = await _runningProcessNames();
    if (names.isEmpty) return const [];
    final detected = <DetectedGame>[];
    for (final entry in _registry.entries) {
      final running = entry.processNames.any(
        (process) => names.contains(process.toLowerCase()),
      );
      if (running) {
        detected.add(
          DetectedGame(
            gameId: entry.gameId,
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

  Future<List<DetectedGame>> _detectKnownInstallPaths() async {
    final detected = <DetectedGame>[];
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
            DetectedGame(
              gameId: entry.gameId,
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
        if (programFiles != null) '$programFiles\\Epic Games',
        if (programFilesX86 != null) '$programFilesX86\\GOG Galaxy\\Games',
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
        if (home != null) '$home/Games',
        '/usr/local/games',
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

  List<DetectedGame> _dedupe(List<DetectedGame> games) {
    final seen = <String>{};
    final unique = <DetectedGame>[];
    for (final game in games) {
      final key = '${game.gameId}:${game.path}';
      if (seen.add(key)) unique.add(game);
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
