import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tasko/core/dates.dart';
import 'package:tasko/core/l10n/app_strings.dart';
import 'package:tasko/core/reschedule_shortcuts_preference.dart';
import 'package:tasko/core/theme.dart';
import 'package:tasko/data/providers.dart';
import 'package:tasko/domain/models.dart';
import 'package:tasko/features/home/home_shell.dart';
import 'package:tasko/features/tasks/reschedule_sheet.dart';

class TaskTile extends ConsumerWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.labels,
    this.selecting = false,
    this.selected = false,
    this.onToggleSelect,
  });

  final TaskItem task;
  final List<TaskLabel> labels;
  final bool selecting;
  final bool selected;
  final VoidCallback? onToggleSelect;

  Color _priorityColor(int p, Brightness brightness) => switch (p) {
        1 => TaskoColors.danger,
        2 => const Color(0xFFE07A3D),
        3 => TaskoColors.amber,
        _ => brightness == Brightness.dark
            ? TaskoColors.nightBorder
            : TaskoColors.mistDeep,
      };

  Future<void> _reschedule(BuildContext context, WidgetRef ref) async {
    final shortcuts = ref.read(rescheduleShortcutsProvider);
    final due = await showRescheduleSheet(
      context: context,
      shortcuts: shortcuts,
    );
    if (due == null || !context.mounted) return;
    try {
      await ref.read(tasksRepositoryProvider).rescheduleTasks([task], due);
      invalidateTaskCaches(ref.invalidate, listIds: [task.listId]);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.rescheduledCount(1))),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.rescheduleFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskLabels =
        labels.where((l) => task.labelIds.contains(l.id)).toList();
    final dueText = formatDue(task.dueDate);
    final overdue = isOverdue(task.dueDate);
    final canSelect = selecting && overdue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (canSelect) {
            onToggleSelect?.call();
            return;
          }
          context.push('/task/${task.listId}/${task.id}');
        },
        onLongPress: overdue && !selecting
            ? () => _reschedule(context, ref)
            : (overdue ? onToggleSelect : null),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: selecting
                    ? Checkbox(
                        value: selected,
                        onChanged:
                            overdue ? (_) => onToggleSelect?.call() : null,
                      )
                    : IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () async {
                          final repo = ref.read(tasksRepositoryProvider);
                          await repo.toggleCompleted(task);
                          invalidateTaskCaches(
                            ref.invalidate,
                            listIds: [task.listId],
                          );
                          ref.read(celebrateTickProvider.notifier).state++;
                        },
                        icon: Icon(
                          Icons.circle_outlined,
                          color: _priorityColor(
                            task.priority,
                            Theme.of(context).brightness,
                          ),
                        ),
                      ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    if (dueText.isNotEmpty || taskLabels.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (dueText.isNotEmpty)
                            Text(
                              dueText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: overdue
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ...taskLabels.map(
                            (l) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: l.color.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: l.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (overdue && !selecting)
                IconButton(
                  tooltip: AppStrings.reschedule,
                  onPressed: () => _reschedule(context, ref),
                  icon: const Icon(Icons.event_repeat_rounded),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
