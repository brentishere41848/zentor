import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zentor_client/core/security/hash_service.dart';

void main() {
  test('HashService hashes a selected file', () async {
    final directory = await Directory.systemTemp.createTemp('zentor_hash_test');
    final file = File('${directory.path}${Platform.pathSeparator}sample.bin');
    await file.writeAsString('zentor-test-file');

    final hash = await HashService().sha256ForFile(file.path);

    expect(
      hash,
      'sha256:e4b8dc0aed2e59d0216bdecec200a9c2786a6ced97c117cef8cde85f86d3f9d9',
    );
    await directory.delete(recursive: true);
  });
}
