import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zentor_client/app/theme/zentor_theme.dart';
import 'package:zentor_client/shared/widgets/zentor_bottom_nav.dart';
import 'package:zentor_client/shared/widgets/zentor_sidebar.dart';

void main() {
  testWidgets('desktop sidebar exposes navigation landmark and selected page', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ZentorTheme.dark(),
        home: const Scaffold(body: ZentorSidebar(location: '/scan')),
      ),
    );

    expect(find.bySemanticsLabel('Primary navigation'), findsOneWidget);
    expect(find.bySemanticsLabel('Current page, Scan'), findsOneWidget);
    expect(find.bySemanticsLabel('Open Quarantine'), findsOneWidget);
  });

  testWidgets('mobile bottom navigation exposes current page semantic label', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ZentorTheme.dark(),
        home: const Scaffold(
          bottomNavigationBar: ZentorBottomNav(location: '/settings'),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Current page, Settings'), findsOneWidget);
    expect(find.byTooltip('Open Settings'), findsOneWidget);
  });
}
