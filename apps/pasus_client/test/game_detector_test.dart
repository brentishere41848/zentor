import 'package:flutter_test/flutter_test.dart';
import 'package:pasus_client/core/games/game_detector.dart';

void main() {
  test(
    'game detector returns empty when no real supported games are found',
    () async {
      final games = await GameDetector().detect();
      expect(games, isEmpty);
    },
  );
}
