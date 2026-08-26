import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasko/core/constants.dart';
import 'package:tasko/core/l10n/app_strings.dart';
import 'package:tasko/core/today_layout_preference.dart';
import 'package:tasko/features/settings/settings_screen.dart';

import 'support/github_test_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  Widget settings({GithubReleasesClient? github}) {
    return ProviderScope(
      overrides: taskoTestOverrides(prefs, github: github),
      child: const MaterialApp(home: SettingsScreen()),
    );
  }

  testWidgets('settings can split Today from Overdue and persist it',
      (tester) async {
    await tester.pumpWidget(settings());
    await tester.pump();

    expect(find.text(AppStrings.todayLayoutCombined), findsOneWidget);
    expect(find.text(AppStrings.tomorrow), findsOneWidget);
    expect(find.text(AppStrings.nextWeek), findsOneWidget);
    expect(find.text('Next Monday'), findsOneWidget);

    await tester.tap(find.text(AppStrings.todayLayoutSplit));
    await tester.pump();

    expect(prefs.getString(TodayLayout.storageKey), 'split');
  });

  testWidgets('settings shows version and can check for updates',
      (tester) async {
    await tester.pumpWidget(
      settings(
        github: ScriptedGithubReleasesClient(
          newerThanInstalledRelease(notes: 'Next'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(AppConstants.versionLabel), findsOneWidget);
    expect(find.text(AppStrings.checkForUpdates), findsOneWidget);

    await tester.tap(find.text(AppStrings.checkForUpdates));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(AppStrings.updateAvailable), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text(AppStrings.later));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(AppStrings.updateAvailable), findsNothing);
  });
}
