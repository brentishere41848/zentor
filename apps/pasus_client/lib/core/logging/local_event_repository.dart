import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pasus_protocol/pasus_protocol.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class LocalEventRepository {
  LocalEventRepository(this._preferences);

  static const _eventsKey = 'pasus.local_events.v1';
  static const _uuid = Uuid();

  final SharedPreferences _preferences;

  List<LocalEvent> load() {
    final raw = _preferences.getString(_eventsKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }
    return decoded
        .whereType<Map>()
        .map((item) => LocalEvent.fromJson(Map<String, Object?>.from(item)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<LocalEvent> add(String type, String message, {String? details}) async {
    final event = LocalEvent(
      id: _uuid.v4(),
      type: type,
      message: message,
      createdAt: DateTime.now().toUtc(),
      details: details,
    );
    final events = [event, ...load()].take(200).toList();
    await _preferences.setString(
      _eventsKey,
      jsonEncode(events.map((event) => event.toJson()).toList()),
    );
    return event;
  }

  Future<void> clear() async {
    await _preferences.remove(_eventsKey);
  }

  Future<File> export() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}${Platform.pathSeparator}pasus-local-events.json',
    );
    final body = const JsonEncoder.withIndent(
      '  ',
    ).convert(load().map((event) => event.toJson()).toList());
    await file.writeAsString(body);
    return file;
  }
}
