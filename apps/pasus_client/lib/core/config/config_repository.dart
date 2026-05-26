import 'dart:convert';

import 'package:pasus_protocol/pasus_protocol.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'build_config.dart';

class ConfigRepository {
  ConfigRepository(this._preferences, {this.buildConfig = const BuildConfig()});

  static const _configKey = 'pasus.config.v1';

  final SharedPreferences _preferences;
  final BuildConfig buildConfig;

  PasusConfig load() {
    final raw = _preferences.getString(_configKey);
    if (raw == null || raw.isEmpty) {
      return _buildConfigDefaults();
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, Object?>) {
      return _buildConfigDefaults();
    }
    final stored = PasusConfig.fromJson(decoded);
    if (stored.developerOverrideEnabled) {
      return stored;
    }
    return stored.copyWith(
      apiBaseUrl: buildConfig.apiBaseUrl,
      projectId: buildConfig.projectId,
      publicGameKey: buildConfig.publicGameKey,
    );
  }

  Future<void> save(PasusConfig config) async {
    await _preferences.setString(_configKey, jsonEncode(config.toJson()));
  }

  Future<void> reset() async {
    await _preferences.remove(_configKey);
  }

  PasusConfig _buildConfigDefaults() => PasusConfig(
    apiBaseUrl: buildConfig.apiBaseUrl,
    projectId: buildConfig.projectId,
    publicGameKey: buildConfig.publicGameKey,
  );
}
