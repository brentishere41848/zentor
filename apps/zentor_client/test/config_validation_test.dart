import 'package:flutter_test/flutter_test.dart';
import 'package:zentor_client/core/config/build_config.dart';
import 'package:zentor_protocol/zentor_protocol.dart';

void main() {
  test('build config has production defaults', () {
    const config = BuildConfig();
    expect(config.apiBaseUrl, 'http://127.0.0.1:8000');
    expect(config.projectId, 'avorax-default');
    expect(config.publicClientKey, 'avorax-public-client');
    expect(config.updatesRepoOwner, 'brentishere41848');
    expect(config.updatesRepoName, 'Avorax');
  });

  test('config validation uses cloud wording instead of form errors', () {
    const empty = ZentorConfig();
    expect(
      empty.validateCloudConfiguration().join(' '),
      contains(
        'Cloud settings are managed by your Avorax build configuration.',
      ),
    );

    const valid = ZentorConfig(
      apiBaseUrl: 'http://127.0.0.1:8000',
      projectId: 'project-1',
      publicClientKey: 'public-key',
    );
    expect(valid.validateCloudConfiguration(), isEmpty);
  });

  test(
    'ransomware protection paths and trusted processes survive config json',
    () {
      const config = ZentorConfig(
        ransomwareProtectedRoots: ['C:/Users/Test/Documents'],
        ransomwareTrustedProcesses: ['C:/Program Files/Backup/backup.exe'],
      );

      final restored = ZentorConfig.fromJson(config.toJson());

      expect(restored.ransomwareProtectedRoots, ['C:/Users/Test/Documents']);
      expect(restored.ransomwareTrustedProcesses, [
        'C:/Program Files/Backup/backup.exe',
      ]);
    },
  );
  test('real-time protection preference survives config json', () {
    const config = ZentorConfig(realtimeProtectionEnabled: true);

    final restored = ZentorConfig.fromJson(config.toJson());

    expect(restored.realtimeProtectionEnabled, isTrue);
  });
}
