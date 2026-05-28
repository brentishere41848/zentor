import 'package:flutter_test/flutter_test.dart';
import 'package:zentor_protocol/zentor_protocol.dart';

void main() {
  test('ProtectionStatus has exact labels', () {
    expect(ProtectionStatus.idle.label, 'Protection Idle');
    expect(ProtectionStatus.localOnly.label, 'Local Protection Active');
    expect(ProtectionStatus.protected.label, 'Protected');
    expect(ProtectionStatus.partiallyProtected.label, 'Partially Protected');
    expect(ProtectionStatus.error.label, 'Protection Error');
  });
}
