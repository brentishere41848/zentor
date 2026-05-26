import 'package:flutter_test/flutter_test.dart';
import 'package:pasus_client/core/logging/local_event_repository.dart';
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
}
