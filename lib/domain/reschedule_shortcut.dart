import 'package:equatable/equatable.dart';
import 'package:tasko/core/dates.dart';
import 'package:tasko/core/l10n/app_strings.dart';

enum RescheduleKind { tomorrow, nextWeek, inDays, nextWeekday }

/// User-configurable due-date jump for overdue tasks.
class RescheduleShortcut extends Equatable {
  const RescheduleShortcut({
    required this.id,
    required this.kind,
    this.dayCount,
    this.weekday,
  });

  final String id;
  final RescheduleKind kind;

  /// Used when [kind] is [RescheduleKind.inDays].
  final int? dayCount;

  /// `DateTime.monday`–`DateTime.sunday` when [kind] is [RescheduleKind.nextWeekday].
  final int? weekday;

  static const List<RescheduleShortcut> defaults = [
    RescheduleShortcut(id: 'tomorrow', kind: RescheduleKind.tomorrow),
    RescheduleShortcut(id: 'nextWeek', kind: RescheduleKind.nextWeek),
    RescheduleShortcut(
      id: 'nextMonday',
      kind: RescheduleKind.nextWeekday,
      weekday: DateTime.monday,
    ),
  ];

  String get label => switch (kind) {
        RescheduleKind.tomorrow => AppStrings.tomorrow,
        RescheduleKind.nextWeek => AppStrings.nextWeek,
        RescheduleKind.inDays => AppStrings.inDays(dayCount ?? 1),
        RescheduleKind.nextWeekday =>
          AppStrings.nextWeekday(weekday ?? DateTime.monday),
      };

  /// Next due date from [now] (calendar day, local).
  DateTime resolve([DateTime? now]) {
    final today = calendarToday(now);
    switch (kind) {
      case RescheduleKind.tomorrow:
        return today.add(const Duration(days: 1));
      case RescheduleKind.nextWeek:
        return today.add(const Duration(days: 7));
      case RescheduleKind.inDays:
        final days = (dayCount ?? 1).clamp(1, 30);
        return today.add(Duration(days: days));
      case RescheduleKind.nextWeekday:
        final target = weekday ?? DateTime.monday;
        var candidate = today.add(const Duration(days: 1));
        while (candidate.weekday != target) {
          candidate = candidate.add(const Duration(days: 1));
        }
        return candidate;
    }
  }

  bool sameTargetAs(RescheduleShortcut other) {
    if (kind != other.kind) return false;
    return switch (kind) {
      RescheduleKind.tomorrow || RescheduleKind.nextWeek => true,
      RescheduleKind.inDays => dayCount == other.dayCount,
      RescheduleKind.nextWeekday => weekday == other.weekday,
    };
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        if (dayCount != null) 'dayCount': dayCount,
        if (weekday != null) 'weekday': weekday,
      };

  static RescheduleShortcut? tryFromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final kindName = json['kind'] as String?;
    if (id == null || id.isEmpty || kindName == null) return null;
    final kind = RescheduleKind.values.where((k) => k.name == kindName);
    if (kind.isEmpty) return null;
    final parsed = RescheduleShortcut(
      id: id,
      kind: kind.first,
      dayCount: json['dayCount'] as int?,
      weekday: json['weekday'] as int?,
    );
    if (parsed.kind == RescheduleKind.inDays &&
        (parsed.dayCount == null || parsed.dayCount! < 1)) {
      return null;
    }
    if (parsed.kind == RescheduleKind.nextWeekday &&
        (parsed.weekday == null ||
            parsed.weekday! < DateTime.monday ||
            parsed.weekday! > DateTime.sunday)) {
      return null;
    }
    return parsed;
  }

  @override
  List<Object?> get props => [id, kind, dayCount, weekday];
}
