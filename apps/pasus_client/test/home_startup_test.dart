import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pasus_client/app/app_state.dart';
import 'package:pasus_client/app/pasus_app.dart';
import 'package:pasus_client/core/network/pasus_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('startup does not show API form or red required validation', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final apiClient = PasusApiClient(
      httpClient: MockClient((request) async => http.Response('offline', 503)),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          apiClientProvider.overrideWithValue(apiClient),
        ],
        child: const PasusApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('API Base URL'), findsNothing);
    expect(find.textContaining('required'), findsNothing);
    expect(find.textContaining('No game configured'), findsNothing);
    expect(find.textContaining('No game selected'), findsNothing);
    expect(find.textContaining('Cloud: Disabled'), findsWidgets);
    expect(find.text('Run Quick Scan'), findsWidgets);
    expect(find.text('Run Full Scan'), findsWidgets);
  });
}
