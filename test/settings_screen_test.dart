import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasko/core/l10n/app_strings.dart';
import 'package:tasko/core/theme_preference.dart';
import 'package:tasko/core/today_layout_preference.dart';
import 'package:tasko/features/settings/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  testWidgets('settings can split Today from Overdue and persist it',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();

    expect(find.text(AppStrings.todayLayoutCombined), findsOneWidget);
    expect(find.text(AppStrings.tomorrow), findsOneWidget);
    expect(find.text(AppStrings.nextWeek), findsOneWidget);
    expect(find.text('Next Monday'), findsOneWidget);

    await tester.tap(find.text(AppStrings.todayLayoutSplit));
    await tester.pump();

    expect(prefs.getString(TodayLayout.storageKey), 'split');
  });
}
