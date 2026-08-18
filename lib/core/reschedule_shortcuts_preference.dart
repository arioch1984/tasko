import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasko/core/theme_preference.dart';
import 'package:tasko/domain/reschedule_shortcut.dart';

class RescheduleShortcutsNotifier
    extends StateNotifier<List<RescheduleShortcut>> {
  RescheduleShortcutsNotifier({
    required List<RescheduleShortcut> initial,
    required Future<void> Function(List<RescheduleShortcut> shortcuts) persist,
  })  : _persist = persist,
        super(initial);

  static const storageKey = 'reschedule_shortcuts';
  static const maxShortcuts = 8;

  final Future<void> Function(List<RescheduleShortcut> shortcuts) _persist;

  Future<void> _commit(List<RescheduleShortcut> next) async {
    state = next;
    await _persist(next);
  }

  Future<bool> add(RescheduleShortcut shortcut) async {
    if (state.length >= maxShortcuts) return false;
    if (state.any(shortcut.sameTargetAs)) return false;
    await _commit([...state, shortcut]);
    return true;
  }

  Future<void> remove(String id) =>
      _commit(state.where((s) => s.id != id).toList());

  Future<void> reorder(int from, int to) async {
    if (from < 0 || from >= state.length) return;
    if (to < 0 || to >= state.length) return;
    if (from == to) return;
    final next = [...state];
    final item = next.removeAt(from);
    next.insert(to, item);
    await _commit(next);
  }

  static List<RescheduleShortcut> fromStorage(String? raw) {
    if (raw == null || raw.isEmpty) return RescheduleShortcut.defaults;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return RescheduleShortcut.defaults;
      final parsed = decoded
          .whereType<Map>()
          .map((e) => RescheduleShortcut.tryFromJson(
                Map<String, dynamic>.from(e),
              ))
          .whereType<RescheduleShortcut>()
          .toList();
      return parsed.isEmpty ? RescheduleShortcut.defaults : parsed;
    } catch (_) {
      return RescheduleShortcut.defaults;
    }
  }

  static String encode(List<RescheduleShortcut> shortcuts) {
    return jsonEncode(shortcuts.map((s) => s.toJson()).toList());
  }
}

final rescheduleShortcutsProvider = StateNotifierProvider<
    RescheduleShortcutsNotifier, List<RescheduleShortcut>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return RescheduleShortcutsNotifier(
    initial: RescheduleShortcutsNotifier.fromStorage(
      prefs.getString(RescheduleShortcutsNotifier.storageKey),
    ),
    persist: (shortcuts) async {
      await prefs.setString(
        RescheduleShortcutsNotifier.storageKey,
        RescheduleShortcutsNotifier.encode(shortcuts),
      );
    },
  );
});
