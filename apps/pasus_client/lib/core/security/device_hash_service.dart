import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

class DeviceHashService {
  String deviceIdentifierHashStatus() {
    final source = '${Platform.operatingSystem}:${Platform.localHostname}';
    final digest = sha256.convert(utf8.encode(source)).toString();
    return 'Hashed identifier ready (${digest.substring(0, 10)}...)';
  }
}
