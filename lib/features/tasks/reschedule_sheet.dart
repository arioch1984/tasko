import 'package:flutter/material.dart';
import 'package:tasko/core/l10n/app_strings.dart';
import 'package:tasko/domain/reschedule_shortcut.dart';

Future<DateTime?> showRescheduleSheet({
  required BuildContext context,
  required List<RescheduleShortcut> shortcuts,
  int taskCount = 1,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  taskCount <= 1
                      ? AppStrings.reschedule
                      : AppStrings.rescheduleCount(taskCount),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final shortcut in shortcuts)
                ListTile(
                  leading: Icon(_iconFor(shortcut.kind)),
                  title: Text(shortcut.label),
                  onTap: () => Navigator.pop(context, shortcut.resolve()),
                ),
              ListTile(
                leading: const Icon(Icons.calendar_today_rounded),
                title: const Text(AppStrings.pickADate),
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: now.add(const Duration(days: 1)),
                    firstDate: DateTime(now.year - 1),
                    lastDate: DateTime(now.year + 10),
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context, picked);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

IconData _iconFor(RescheduleKind kind) => switch (kind) {
      RescheduleKind.tomorrow => Icons.wb_sunny_outlined,
      RescheduleKind.nextWeek => Icons.next_week_outlined,
      RescheduleKind.inDays => Icons.more_time_rounded,
      RescheduleKind.nextWeekday => Icons.date_range_rounded,
    };
