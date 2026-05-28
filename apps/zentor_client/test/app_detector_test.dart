import 'package:flutter_test/flutter_test.dart';
import 'package:zentor_client/core/apps/app_detector.dart';

void main() {
  test(
    'app detector returns empty when no real supported apps are found',
    () async {
      final apps = await AppDetector().detect();
      expect(apps, isEmpty);
    },
  );
}
