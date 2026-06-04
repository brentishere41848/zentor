import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zentor_client/app/app_state.dart';
import 'package:zentor_client/app/theme/zentor_theme.dart';
import 'package:zentor_client/core/apps/app_detector.dart';
import 'package:zentor_client/features/settings/settings_screen.dart';
import 'package:zentor_protocol/zentor_protocol.dart';

class _FakeAppDetector extends AppDetector {
  const _FakeAppDetector();

  @override
  Future<List<DetectedApp>> detect() async => const [];
}

void main() {
  testWidgets('settings exposes screen-reader section headers', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          appDetectorProvider.overrideWithValue(const _FakeAppDetector()),
        ],
        child: MaterialApp(
          theme: ZentorTheme.dark(),
          home: const Scaffold(
            body: SingleChildScrollView(child: SettingsScreen()),
          ),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel('Settings section, Protection'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Settings section, Avorax Native Engine'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Settings section, Diagnostics'),
      findsOneWidget,
    );
  });
}
