import 'package:flutter_test/flutter_test.dart';
import 'package:pasus_client/core/config/build_config.dart';
import 'package:pasus_protocol/pasus_protocol.dart';

void main() {
  test('build config has production defaults', () {
    const config = BuildConfig();
    expect(config.apiBaseUrl, 'http://127.0.0.1:8000');
    expect(config.projectId, 'pasus-default');
    expect(config.publicGameKey, 'pasus-public-client');
  });

  test('config validation uses cloud wording instead of form errors', () {
    const empty = PasusConfig();
    expect(
      empty.validateCloudConfiguration().join(' '),
      contains('Cloud settings are managed by your Pasus build configuration.'),
    );

    const valid = PasusConfig(
      apiBaseUrl: 'http://127.0.0.1:8000',
      projectId: 'project-1',
      publicGameKey: 'public-key',
    );
    expect(valid.validateCloudConfiguration(), isEmpty);
  });
}
