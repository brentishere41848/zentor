import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pasus_client/core/security/hash_service.dart';

void main() {
  test('HashService hashes a selected file', () async {
    final directory = await Directory.systemTemp.createTemp('pasus_hash_test');
    final file = File('${directory.path}${Platform.pathSeparator}game.bin');
    await file.writeAsString('pasus-test-file');

    final hash = await HashService().sha256ForFile(file.path);

    expect(
      hash,
      'sha256:c0bbc5cb4e4172b8c561618d73331442a839a2f4e82dd3cc6930582b886ed064',
    );
    await directory.delete(recursive: true);
  });
}
