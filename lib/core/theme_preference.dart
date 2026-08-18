import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-facing appearance choice. [system] follows the device setting.
enum ThemePreference {
  system,
  light,
  dark;

  static const storageKey = 'theme_preference';

  static ThemePreference fromStorage(String? value) {
    return switch (value) {
      'light' => ThemePreference.light,
      'dark' => ThemePreference.dark,
      _ => ThemePreference.system,
    };
  }

  String get storageValue => name;

  ThemeMode get themeMode => switch (this) {
        ThemePreference.system => ThemeMode.system,
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
      };

  IconData get icon => switch (this) {
        ThemePreference.system => Icons.brightness_auto_rounded,
        ThemePreference.light => Icons.light_mode_rounded,
        ThemePreference.dark => Icons.dark_mode_rounded,
      };
}

class ThemePreferenceNotifier extends StateNotifier<ThemePreference> {
  ThemePreferenceNotifier({
    required ThemePreference initial,
    required Future<void> Function(ThemePreference preference) persist,
  })  : _persist = persist,
        super(initial);

  final Future<void> Function(ThemePreference preference) _persist;

  Future<void> setPreference(ThemePreference preference) async {
    if (preference == state) return;
    state = preference;
    await _persist(preference);
  }
}

/// Must be overridden with [SharedPreferences.getInstance] before [runApp].
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError(
    'sharedPreferencesProvider must be overridden with SharedPreferences',
  );
});

final themePreferenceProvider =
    StateNotifierProvider<ThemePreferenceNotifier, ThemePreference>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemePreferenceNotifier(
    initial: ThemePreference.fromStorage(
      prefs.getString(ThemePreference.storageKey),
    ),
    persist: (preference) async {
      await prefs.setString(
        ThemePreference.storageKey,
        preference.storageValue,
      );
    },
  );
});
