import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pasus_client/core/scanning/scan_target_service.dart';

void main() {
  test('quick scan selects common user risk locations', () {
    final root = Directory.systemTemp.createTempSync('pasus-quick-');
    addTearDown(() => root.deleteSync(recursive: true));
    Directory('${root.path}${Platform.pathSeparator}Downloads').createSync();
    Directory('${root.path}${Platform.pathSeparator}Desktop').createSync();

    final targets = const ScanTargetService().quickScanTargets(
      environment: {'HOME': root.path, 'USERPROFILE': root.path},
    );

    expect(targets.any((path) => path.endsWith('Downloads')), isTrue);
    expect(targets.any((path) => path.endsWith('Desktop')), isTrue);
  });

  test('full scan roots include accessible home area', () {
    final root = Directory.systemTemp.createTempSync('pasus-full-');
    addTearDown(() => root.deleteSync(recursive: true));

    final roots = const ScanTargetService().fullScanRoots(
      environment: {'HOME': root.path, 'USERPROFILE': root.path},
    );

    if (Platform.isWindows) {
      expect(roots.any((path) => path.endsWith(r':\')), isTrue);
    } else {
      expect(roots, contains(root.path));
    }
  });
}
