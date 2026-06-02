import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zentor_client/core/local_core/local_core_client.dart';
import 'package:zentor_protocol/zentor_protocol.dart';

void main() {
  test('scan failure reports missing local core executable path', () async {
    final missing = Directory.systemTemp
        .createTempSync('avorax-missing-core-')
        .uri
        .resolve('missing-core.exe')
        .toFilePath();
    addTearDown(() {
      final parent = File(missing).parent;
      if (parent.existsSync()) parent.deleteSync(recursive: true);
    });

    final client = LocalCoreClient(executableOverride: missing);

    final report = await client.scanFile(
      'C:/Users/Brent/Downloads/sample.exe',
      kind: ScanKind.custom,
      actionMode: ScanActionMode.detectOnly,
    );

    expect(report.status, ScanStatus.engineUnavailable);
    expect(
      report.message,
      contains('Avorax Core Service executable was not found'),
    );
    expect(report.message, contains(missing));
  });
  test(
    'health summary exposes IPC failure as lastError for recovery UI',
    () async {
      final missing = Directory.systemTemp
          .createTempSync('avorax-missing-health-core-')
          .uri
          .resolve('missing-core.exe')
          .toFilePath();
      addTearDown(() {
        final parent = File(missing).parent;
        if (parent.existsSync()) parent.deleteSync(recursive: true);
      });

      final client = LocalCoreClient(executableOverride: missing);

      final health = await client.healthSummary();

      expect(health.coreServiceStatus, 'error');
      expect(
        health.lastError,
        contains('Avorax Core Service executable was not found'),
      );
      expect(health.lastError, contains(missing));
    },
  );

  test('scan failure preserves stderr from local core process', () async {
    final dir = Directory.systemTemp.createTempSync('avorax-core-stderr-');
    addTearDown(() => dir.deleteSync(recursive: true));
    final script = File('${dir.path}${Platform.pathSeparator}stderr.dart')
      ..writeAsStringSync('''
import 'dart:io';
void main() {
  stderr.writeln('native engine assets missing');
  exitCode = 7;
}
''');

    final client = LocalCoreClient(
      executableOverride: _dartExecutable(),
      executableArguments: [script.path],
    );

    final report = await client.scanFile(
      'C:/Users/Brent/Downloads/sample.exe',
      kind: ScanKind.custom,
      actionMode: ScanActionMode.detectOnly,
    );

    expect(report.status, ScanStatus.engineUnavailable);
    expect(report.message, contains('native engine assets missing'));
    expect(report.message, contains('exit code 7'));
  });

  test('scan failure reports malformed local core JSON', () async {
    final dir = Directory.systemTemp.createTempSync('avorax-core-malformed-');
    addTearDown(() => dir.deleteSync(recursive: true));
    final script = File('${dir.path}${Platform.pathSeparator}malformed.dart')
      ..writeAsStringSync('''
void main() {
  print('not-json');
}
''');

    final client = LocalCoreClient(
      executableOverride: _dartExecutable(),
      executableArguments: [script.path],
    );

    final report = await client.scanFile(
      'C:/Users/Brent/Downloads/sample.exe',
      kind: ScanKind.custom,
      actionMode: ScanActionMode.detectOnly,
    );

    expect(report.status, ScanStatus.engineUnavailable);
    expect(report.message, contains('malformed JSON'));
    expect(report.message, contains('not-json'));
  });

  test('scan failure reports local core timeout and kills process', () async {
    final dir = Directory.systemTemp.createTempSync('avorax-core-timeout-');
    addTearDown(() => dir.deleteSync(recursive: true));
    final script = File('${dir.path}${Platform.pathSeparator}timeout.dart')
      ..writeAsStringSync('''
import 'dart:async';
Future<void> main() async {
  await Future<void>.delayed(const Duration(seconds: 5));
}
''');

    final client = LocalCoreClient(
      executableOverride: _dartExecutable(),
      executableArguments: [script.path],
      ipcTimeout: const Duration(milliseconds: 100),
    );

    final report = await client.scanFile(
      'C:/Users/Brent/Downloads/sample.exe',
      kind: ScanKind.custom,
      actionMode: ScanActionMode.detectOnly,
    );

    expect(report.status, ScanStatus.engineUnavailable);
    expect(report.message, contains('timed out'));
    expect(report.message, contains('100ms'));
  });
}

String _dartExecutable() {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  final candidates = [
    if (flutterRoot != null)
      '$flutterRoot${Platform.pathSeparator}bin${Platform.pathSeparator}cache${Platform.pathSeparator}dart-sdk${Platform.pathSeparator}bin${Platform.pathSeparator}dart.exe',
    r'C:\Users\Brent\develop\flutter\bin\cache\dart-sdk\bin\dart.exe',
    Platform.resolvedExecutable,
  ];
  return candidates.firstWhere((path) => File(path).existsSync());
}
