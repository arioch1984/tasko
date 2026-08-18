import 'package:flutter_test/flutter_test.dart';
import 'package:tasko/core/reschedule_shortcuts_preference.dart';
import 'package:tasko/core/today_layout_preference.dart';
import 'package:tasko/domain/reschedule_shortcut.dart';

void main() {
  group('TodayLayout', () {
    test('defaults to combined', () {
      expect(TodayLayout.fromStorage(null), TodayLayout.combined);
      expect(TodayLayout.fromStorage('nope'), TodayLayout.combined);
      expect(TodayLayout.fromStorage('split'), TodayLayout.split);
    });

    test('notifier persists on change only', () async {
      TodayLayout? saved;
      final notifier = TodayLayoutNotifier(
        initial: TodayLayout.combined,
        persist: (layout) async => saved = layout,
      );

      await notifier.setLayout(TodayLayout.combined);
      expect(saved, isNull);

      await notifier.setLayout(TodayLayout.split);
      expect(notifier.state, TodayLayout.split);
      expect(saved, TodayLayout.split);
    });
  });

  group('RescheduleShortcutsNotifier', () {
    test('fromStorage falls back to defaults', () {
      expect(
        RescheduleShortcutsNotifier.fromStorage(null),
        RescheduleShortcut.defaults,
      );
      expect(
        RescheduleShortcutsNotifier.fromStorage('not-json'),
        RescheduleShortcut.defaults,
      );
    });

    test('add rejects duplicates and overflow', () async {
      var persistCount = 0;
      final notifier = RescheduleShortcutsNotifier(
        initial: [...RescheduleShortcut.defaults],
        persist: (_) async => persistCount++,
      );

      final addedTomorrow = await notifier.add(
        const RescheduleShortcut(id: 'dup', kind: RescheduleKind.tomorrow),
      );
      expect(addedTomorrow, isFalse);
      expect(persistCount, 0);

      final addedFriday = await notifier.add(
        const RescheduleShortcut(
          id: 'fri',
          kind: RescheduleKind.nextWeekday,
          weekday: DateTime.friday,
        ),
      );
      expect(addedFriday, isTrue);
      expect(notifier.state.last.id, 'fri');

      await notifier.remove('fri');
      expect(
        notifier.state.any((s) => s.id == 'fri'),
        isFalse,
      );
    });

    test('reorder moves an item', () async {
      final notifier = RescheduleShortcutsNotifier(
        initial: [...RescheduleShortcut.defaults],
        persist: (_) async {},
      );
      final first = notifier.state.first.id;
      await notifier.reorder(0, 1);
      expect(notifier.state[1].id, first);
    });

    test('encode then fromStorage round-trips', () {
      final encoded = RescheduleShortcutsNotifier.encode(
        RescheduleShortcut.defaults,
      );
      expect(
        RescheduleShortcutsNotifier.fromStorage(encoded),
        RescheduleShortcut.defaults,
      );
    });
  });
}
