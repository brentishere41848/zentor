import 'package:flutter_test/flutter_test.dart';
import 'package:zentor_client/core/logging/local_event_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('local event creation persists a real app event', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = LocalEventRepository(preferences);

    final event = await repository.add('app_started', 'App started');

    expect(event.type, 'app_started');
    expect(repository.load(), hasLength(1));
    expect(repository.load().single.message, 'App started');
  });

  test('corrupt local event history is recovered without crashing', () async {
    SharedPreferences.setMockInitialValues({
      'zentor.local_events.v1': '{this is not valid json',
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = LocalEventRepository(preferences);

    expect(repository.load(), isEmpty);

    final event = await repository.add('scan_started', 'Scan started');
    expect(event.type, 'scan_started');
    expect(repository.load(), hasLength(1));
    expect(repository.load().single.message, 'Scan started');
  });
  test(
    'protection and ransomware events persist category and severity',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = LocalEventRepository(preferences);

      final event = await repository.add(
        'ransomware_guard_settings_changed',
        'Ransomware guard settings changed',
        details: '2 protected roots',
        category: 'protection',
        severity: 'warning',
      );

      expect(event.category, 'protection');
      expect(event.severity, 'warning');
      final restored = repository.load().single;
      expect(restored.category, 'protection');
      expect(restored.severity, 'warning');
    },
  );
}
