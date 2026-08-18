import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasko/core/theme_preference.dart';

void main() {
  group('ThemePreference.fromStorage', () {
    test('defaults to system for null, empty, or unknown values', () {
      expect(ThemePreference.fromStorage(null), ThemePreference.system);
      expect(ThemePreference.fromStorage(''), ThemePreference.system);
      expect(ThemePreference.fromStorage('auto'), ThemePreference.system);
    });

    test('parses light and dark', () {
      expect(ThemePreference.fromStorage('light'), ThemePreference.light);
      expect(ThemePreference.fromStorage('dark'), ThemePreference.dark);
      expect(ThemePreference.fromStorage('system'), ThemePreference.system);
    });
  });

  group('ThemePreference mapping', () {
    test('maps to ThemeMode', () {
      expect(ThemePreference.system.themeMode, ThemeMode.system);
      expect(ThemePreference.light.themeMode, ThemeMode.light);
      expect(ThemePreference.dark.themeMode, ThemeMode.dark);
    });

    test('round-trips through storageValue', () {
      for (final preference in ThemePreference.values) {
        expect(
          ThemePreference.fromStorage(preference.storageValue),
          preference,
        );
      }
    });
  });

  group('ThemePreferenceNotifier', () {
    test('setPreference updates state and persists', () async {
      ThemePreference? saved;
      final notifier = ThemePreferenceNotifier(
        initial: ThemePreference.system,
        persist: (preference) async => saved = preference,
      );

      await notifier.setPreference(ThemePreference.dark);

      expect(notifier.state, ThemePreference.dark);
      expect(saved, ThemePreference.dark);
    });

    test('setPreference is a no-op when unchanged', () async {
      var persistCount = 0;
      final notifier = ThemePreferenceNotifier(
        initial: ThemePreference.light,
        persist: (_) async => persistCount++,
      );

      await notifier.setPreference(ThemePreference.light);

      expect(persistCount, 0);
    });
  });
}
