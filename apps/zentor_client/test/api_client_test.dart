import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zentor_client/core/network/api_result.dart';
import 'package:zentor_client/core/network/zentor_api_client.dart';
import 'package:zentor_protocol/zentor_protocol.dart';

void main() {
  test('API client returns failure when endpoint is unavailable', () async {
    final client = ZentorApiClient(
      httpClient: MockClient((request) async {
        throw Exception('connection refused');
      }),
    );

    final result = await client.healthCheck(
      const ZentorConfig(
        apiBaseUrl: 'http://127.0.0.1:1',
        projectId: 'project',
        publicClientKey: 'key',
      ),
    );

    expect(result, isA<ApiFailure<void>>());
  });

  test('API client does not fake non-2xx success', () async {
    final client = ZentorApiClient(
      httpClient: MockClient(
        (request) async => http.Response('not healthy', 503),
      ),
    );

    final result = await client.healthCheck(
      const ZentorConfig(
        apiBaseUrl: 'http://localhost:8080',
        projectId: 'project',
        publicClientKey: 'key',
      ),
    );

    expect(result, isA<ApiFailure<void>>());
  });
}
