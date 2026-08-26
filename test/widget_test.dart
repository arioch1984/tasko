import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasko/app.dart';
import 'package:tasko/core/l10n/app_strings.dart';
import 'package:tasko/core/theme.dart';
import 'package:tasko/core/theme_preference.dart';

import 'support/github_test_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  Widget app({GithubReleasesClient? github}) {
    return ProviderScope(
      overrides: taskoTestOverrides(prefs, github: github),
      child: const TaskoApp(),
    );
  }

  Brightness scaffoldBrightness(WidgetTester tester) {
    return Theme.of(tester.element(find.byType(Scaffold))).brightness;
  }

  testWidgets('TaskoApp builds', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();
    expect(find.text('Tasko'), findsWidgets);
  });

  testWidgets('defaults to system theme mode', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.system);
  });

  testWidgets('system preference follows a dark device', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(app());
    await tester.pump();

    expect(scaffoldBrightness(tester), Brightness.dark);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor ??
          Theme.of(tester.element(find.byType(Scaffold)))
              .scaffoldBackgroundColor,
      TaskoColors.night,
    );
  });

  testWidgets('system preference follows a light device', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(app());
    await tester.pump();

    expect(scaffoldBrightness(tester), Brightness.light);
  });

  testWidgets('forced light ignores a dark device', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await prefs.setString(ThemePreference.storageKey, 'light');

    await tester.pumpWidget(app());
    await tester.pump();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.light);
    expect(scaffoldBrightness(tester), Brightness.light);
  });

  testWidgets('forced dark ignores a light device', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await prefs.setString(ThemePreference.storageKey, 'dark');

    await tester.pumpWidget(app());
    await tester.pump();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
    expect(scaffoldBrightness(tester), Brightness.dark);
  });

  testWidgets('appearance dialog can force dark and persist it', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(app());
    await tester.pump();

    await tester.tap(find.byTooltip(AppStrings.appearance));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text(AppStrings.themeDark));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(scaffoldBrightness(tester), Brightness.dark);
    expect(prefs.getString(ThemePreference.storageKey), 'dark');
  });

  testWidgets('prompts when a newer GitHub release exists', (tester) async {
    await tester.pumpWidget(
      app(
        github: ScriptedGithubReleasesClient(newerThanInstalledRelease()),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text(AppStrings.updateAvailable), findsOneWidget);
    expect(find.text('Fresh build'), findsOneWidget);

    await tester.tap(find.text(AppStrings.later));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(AppStrings.updateAvailable), findsNothing);
  });
}
