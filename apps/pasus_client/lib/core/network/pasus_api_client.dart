import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pasus_protocol/pasus_protocol.dart';

import 'api_result.dart';

class PasusApiClient {
  PasusApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<ApiResult<void>> healthCheck(PasusConfig config) async {
    final validation = config.validateCloudConfiguration();
    if (validation.isNotEmpty) {
      return ApiFailure(validation.join(' '));
    }
    final uri = Uri.parse(config.apiBaseUrl).replace(path: '/v1/health');
    try {
      final response = await _httpClient
          .get(uri)
          .timeout(const Duration(seconds: 6));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const ApiSuccess(null);
      }
      return ApiFailure(
        'Pasus Cloud returned HTTP ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    } on Object catch (error) {
      return ApiFailure('Pasus Cloud is offline: $error');
    }
  }

  Future<ApiResult<ProtectionSession>> createProtectionSession(
    PasusConfig config,
  ) async {
    final validation = config.validateCloudConfiguration();
    if (validation.isNotEmpty) {
      return ApiFailure(validation.join(' '));
    }
    if (!config.gameConfig.isConfigured) {
      return const ApiFailure('No supported game is selected.');
    }
    final uri = Uri.parse(config.apiBaseUrl).replace(path: '/v1/sessions');
    final now = DateTime.now().toUtc();
    final body = {
      'project_id': config.projectId,
      'platform': config.gameConfig.platform,
      'game_version': 'pasus-client',
      'build_hash': config.gameConfig.lastCalculatedHash,
      'device_fingerprint_hash': 'device-hash-managed-locally',
      'nonce': now.microsecondsSinceEpoch.toString(),
      'expires_at': now.add(const Duration(hours: 1)).toIso8601String(),
    };
    try {
      final response = await _httpClient
          .post(uri, headers: _headers(config), body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return ApiFailure(
          'Protection session failed with HTTP ${response.statusCode}.',
          statusCode: response.statusCode,
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, Object?>) {
        return const ApiFailure('Session response was not a JSON object.');
      }
      final sessionId = decoded['session_id'] as String?;
      if (sessionId == null || sessionId.isEmpty) {
        return const ApiFailure('Session response did not include session_id.');
      }
      return ApiSuccess(
        ProtectionSession(
          sessionId: sessionId,
          startedAt: now,
          expiresAt: DateTime.tryParse(decoded['expires_at'] as String? ?? ''),
        ),
      );
    } on Object catch (error) {
      return ApiFailure('Protection session failed: $error');
    }
  }

  Future<ApiResult<void>> sendHeartbeat(
    PasusConfig config,
    ProtectionSession session,
  ) async {
    final uri = Uri.parse(
      config.apiBaseUrl,
    ).replace(path: '/v1/sessions/${session.sessionId}/heartbeat');
    final body = {
      'session_id': session.sessionId,
      'monotonic_time': DateTime.now().millisecondsSinceEpoch,
      'client_timestamp': DateTime.now().toUtc().toIso8601String(),
      'signed_payload': 'visible-pasus-client-heartbeat',
      'environment': {
        'agent_visible': true,
        'kernel_driver': false,
        'unrelated_file_scan': false,
      },
    };
    try {
      final response = await _httpClient
          .post(uri, headers: _headers(config), body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const ApiSuccess(null);
      }
      return ApiFailure(
        'Heartbeat failed with HTTP ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    } on Object catch (error) {
      return ApiFailure('Heartbeat failed: $error');
    }
  }

  Future<ApiResult<void>> endSession(
    PasusConfig config,
    ProtectionSession session,
  ) async {
    final uri = Uri.parse(
      config.apiBaseUrl,
    ).replace(path: '/v1/sessions/${session.sessionId}/end');
    try {
      final response = await _httpClient
          .post(uri, headers: _headers(config))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 404 || response.statusCode == 405) {
        return const ApiSuccess(null);
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const ApiSuccess(null);
      }
      return ApiFailure(
        'End session failed with HTTP ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    } on Object catch (error) {
      return ApiFailure('End session failed: $error');
    }
  }

  Future<ApiResult<void>> reportDetection(
    PasusConfig config,
    ScanReport report,
  ) async {
    final uri = Uri.parse(config.apiBaseUrl).replace(path: '/v1/detections');
    try {
      final response = await _httpClient
          .post(
            uri,
            headers: _headers(config),
            body: jsonEncode({
              'project_id': config.projectId,
              'scan_kind': report.kind.name,
              'action_mode': report.actionMode.name,
              'files_scanned': report.filesScanned,
              'threats_found': report.threatsFound,
              'skipped_files': report.skippedFiles,
              'detections': [
                for (final threat in report.threats)
                  {
                    'path_hash': threat.sha256,
                    'engine': threat.engine,
                    'threat_name': threat.threatName,
                    'detection_type': threat.detectionType.name,
                    'threat_category': threat.threatCategory.name,
                    'confidence': threat.confidence.name,
                    'status': threat.status.name,
                    'detected_at': threat.detectedAt.toIso8601String(),
                  },
              ],
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const ApiSuccess(null);
      }
      return ApiFailure(
        'Detection report failed with HTTP ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    } on Object catch (error) {
      return ApiFailure('Detection report failed: $error');
    }
  }

  Future<ApiResult<void>> uploadQuarantineMetadata(
    PasusConfig config,
    QuarantineRecord record,
  ) async {
    final uri = Uri.parse(config.apiBaseUrl).replace(path: '/v1/quarantine');
    try {
      final response = await _httpClient
          .post(
            uri,
            headers: _headers(config),
            body: jsonEncode({
              'project_id': config.projectId,
              'quarantine_id': record.quarantineId,
              'sha256': record.sha256,
              'detection_name': record.detectionName,
              'engine': record.engine,
              'quarantined_at': record.quarantinedAt.toIso8601String(),
              'status': record.status.name,
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const ApiSuccess(null);
      }
      return ApiFailure(
        'Quarantine metadata upload failed with HTTP ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    } on Object catch (error) {
      return ApiFailure('Quarantine metadata upload failed: $error');
    }
  }

  Map<String, String> _headers(PasusConfig config) => {
    'content-type': 'application/json',
    'authorization': 'Bearer ${config.publicGameKey}',
  };
}
