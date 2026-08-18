import 'package:flutter_test/flutter_test.dart';
import 'package:tasko/core/dates.dart';
import 'package:tasko/domain/reschedule_shortcut.dart';

void main() {
  final wednesday = DateTime(2026, 8, 19); // Wednesday

  group('calendar helpers', () {
    test('isOverdue is true only before today', () {
      expect(isOverdue(DateTime(2026, 8, 18), wednesday), isTrue);
      expect(isOverdue(DateTime(2026, 8, 19), wednesday), isFalse);
      expect(isOverdue(DateTime(2026, 8, 20), wednesday), isFalse);
      expect(isOverdue(null, wednesday), isFalse);
    });

    test('isDueToday ignores time of day', () {
      expect(isDueToday(DateTime(2026, 8, 19, 23, 59), wednesday), isTrue);
      expect(isDueToday(DateTime(2026, 8, 18, 23, 59), wednesday), isFalse);
    });
  });

  group('RescheduleShortcut.resolve', () {
    test('tomorrow is the next calendar day', () {
      const shortcut = RescheduleShortcut(
        id: 't',
        kind: RescheduleKind.tomorrow,
      );
      expect(shortcut.resolve(wednesday), DateTime(2026, 8, 20));
    });

    test('next week is +7 days', () {
      const shortcut = RescheduleShortcut(
        id: 'w',
        kind: RescheduleKind.nextWeek,
      );
      expect(shortcut.resolve(wednesday), DateTime(2026, 8, 26));
    });

    test('in days uses the configured count', () {
      const shortcut = RescheduleShortcut(
        id: 'd',
        kind: RescheduleKind.inDays,
        dayCount: 3,
      );
      expect(shortcut.resolve(wednesday), DateTime(2026, 8, 22));
    });

    test('next weekday skips today when it already is that day', () {
      const monday = RescheduleShortcut(
        id: 'm',
        kind: RescheduleKind.nextWeekday,
        weekday: DateTime.monday,
      );
      expect(monday.resolve(wednesday), DateTime(2026, 8, 24));
      expect(
        monday.resolve(DateTime(2026, 8, 24)),
        DateTime(2026, 8, 31),
      );
    });
  });

  group('RescheduleShortcut json', () {
    test('round-trips defaults', () {
      for (final shortcut in RescheduleShortcut.defaults) {
        final parsed = RescheduleShortcut.tryFromJson(shortcut.toJson());
        expect(parsed, shortcut);
      }
    });

    test('rejects unknown or incomplete payloads', () {
      expect(RescheduleShortcut.tryFromJson({'id': 'x'}), isNull);
      expect(
        RescheduleShortcut.tryFromJson({
          'id': 'x',
          'kind': 'inDays',
        }),
        isNull,
      );
      expect(
        RescheduleShortcut.tryFromJson({
          'id': 'x',
          'kind': 'nextWeekday',
          'weekday': 99,
        }),
        isNull,
      );
    });
  });
}
