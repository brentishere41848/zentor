import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class HashService {
  Future<String> sha256ForFile(
    String path, {
    void Function(double progress)? onProgress,
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      throw const FileSystemException('Selected file does not exist.');
    }
    final stat = await file.stat();
    if (stat.type != FileSystemEntityType.file) {
      throw const FileSystemException(
        'Hashing is limited to a selected file. Folder scanning is not allowed.',
      );
    }

    final total = stat.size;
    var read = 0;
    final bytes = BytesBuilder(copy: false);
    final stream = file.openRead();

    await for (final chunk in stream) {
      read += chunk.length;
      bytes.add(chunk);
      if (total > 0) {
        onProgress?.call(read / total);
      }
    }

    onProgress?.call(1);
    return 'sha256:${sha256.convert(bytes.takeBytes())}';
  }

  bool get supportsPathHashing =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}
