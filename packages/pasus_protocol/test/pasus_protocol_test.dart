import 'package:pasus_protocol/pasus_protocol.dart';
import 'package:test/test.dart';

void main() {
  test('ProtectionStatus maps to user-facing labels', () {
    expect(ProtectionStatus.idle.label, 'Protection Idle');
    expect(ProtectionStatus.protected.label, 'Protected');
    expect(ProtectionStatus.localOnly.label, 'Local Protection Active');
  });

  test('PasusConfig validates cloud settings', () {
    final config = PasusConfig(apiBaseUrl: 'not-a-url');
    expect(config.validateCloudConfiguration(), hasLength(2));

    final valid = PasusConfig(
      apiBaseUrl: 'https://api.pasus.example',
      projectId: 'project',
      publicGameKey: 'key',
    );
    expect(valid.validateCloudConfiguration(), isEmpty);
  });
}
