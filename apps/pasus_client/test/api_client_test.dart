import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pasus_client/core/network/api_result.dart';
import 'package:pasus_client/core/network/pasus_api_client.dart';
import 'package:pasus_protocol/pasus_protocol.dart';

void main() {
  test('API client returns failure when endpoint is unavailable', () async {
    final client = PasusApiClient(
      httpClient: MockClient((request) async {
        throw Exception('connection refused');
      }),
    );

    final result = await client.healthCheck(
      const PasusConfig(
        apiBaseUrl: 'http://127.0.0.1:1',
        projectId: 'project',
        publicGameKey: 'key',
      ),
    );

    expect(result, isA<ApiFailure<void>>());
  });

  test('API client does not fake non-2xx success', () async {
    final client = PasusApiClient(
      httpClient: MockClient(
        (request) async => http.Response('not healthy', 503),
      ),
    );

    final result = await client.healthCheck(
      const PasusConfig(
        apiBaseUrl: 'http://localhost:8080',
        projectId: 'project',
        publicGameKey: 'key',
      ),
    );

    expect(result, isA<ApiFailure<void>>());
  });
}
