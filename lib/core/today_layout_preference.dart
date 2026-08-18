import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasko/core/theme_preference.dart';

/// How the drawer presents due/overdue work.
///
/// [combined] keeps the current Today view (due today + overdue).
/// [split] adds a separate Overdue item and Today shows only today's due date.
enum TodayLayout {
  combined,
  split;

  static const storageKey = 'today_layout';

  static TodayLayout fromStorage(String? value) {
    return switch (value) {
      'split' => TodayLayout.split,
      _ => TodayLayout.combined,
    };
  }

  String get storageValue => name;
}

class TodayLayoutNotifier extends StateNotifier<TodayLayout> {
  TodayLayoutNotifier({
    required TodayLayout initial,
    required Future<void> Function(TodayLayout layout) persist,
  })  : _persist = persist,
        super(initial);

  final Future<void> Function(TodayLayout layout) _persist;

  Future<void> setLayout(TodayLayout layout) async {
    if (layout == state) return;
    state = layout;
    await _persist(layout);
  }
}

final todayLayoutProvider =
    StateNotifierProvider<TodayLayoutNotifier, TodayLayout>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TodayLayoutNotifier(
    initial: TodayLayout.fromStorage(prefs.getString(TodayLayout.storageKey)),
    persist: (layout) async {
      await prefs.setString(TodayLayout.storageKey, layout.storageValue);
    },
  );
});
