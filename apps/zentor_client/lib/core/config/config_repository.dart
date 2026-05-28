import 'dart:convert';

import 'package:zentor_protocol/zentor_protocol.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'build_config.dart';

class ConfigRepository {
  ConfigRepository(this._preferences, {this.buildConfig = const BuildConfig()});

  static const _configKey = 'zentor.config.v1';

  final SharedPreferences _preferences;
  final BuildConfig buildConfig;

  ZentorConfig load() {
    final raw = _preferences.getString(_configKey);
    if (raw == null || raw.isEmpty) {
      return _buildConfigDefaults();
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, Object?>) {
      return _buildConfigDefaults();
    }
    final stored = ZentorConfig.fromJson(decoded);
    if (stored.developerOverrideEnabled) {
      return stored;
    }
    return stored.copyWith(
      apiBaseUrl: buildConfig.apiBaseUrl,
      projectId: buildConfig.projectId,
      publicClientKey: buildConfig.publicClientKey,
    );
  }

  Future<void> save(ZentorConfig config) async {
    await _preferences.setString(_configKey, jsonEncode(config.toJson()));
  }

  Future<void> reset() async {
    await _preferences.remove(_configKey);
  }

  ZentorConfig _buildConfigDefaults() => ZentorConfig(
    apiBaseUrl: buildConfig.apiBaseUrl,
    projectId: buildConfig.projectId,
    publicClientKey: buildConfig.publicClientKey,
  );
}
