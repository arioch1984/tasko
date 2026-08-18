import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tasko/core/theme.dart';
import 'package:tasko/data/providers.dart';
import 'package:tasko/domain/models.dart';
import 'package:tasko/features/home/home_shell.dart';

class TaskTile extends ConsumerWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.labels,
  });

  final TaskItem task;
  final List<TaskLabel> labels;

  Color _priorityColor(int p, Brightness brightness) => switch (p) {
        1 => TaskoColors.danger,
        2 => const Color(0xFFE07A3D),
        3 => TaskoColors.amber,
        _ => brightness == Brightness.dark
            ? TaskoColors.nightBorder
            : TaskoColors.mistDeep,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskLabels =
        labels.where((l) => task.labelIds.contains(l.id)).toList();
    final dueText = formatDue(task.dueDate);
    final overdue = task.dueDate != null &&
        task.dueDate!
            .isBefore(DateTime.now().subtract(const Duration(days: 0))) &&
        DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day)
            .isBefore(DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            ));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/task/${task.listId}/${task.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () async {
                    final repo = ref.read(tasksRepositoryProvider);
                    await repo.toggleCompleted(task);
                    ref.invalidate(listTasksProvider(task.listId));
                    ref.invalidate(allOpenTasksProvider);
                    ref.invalidate(todayTasksProvider);
                    ref.invalidate(upcomingTasksProvider);
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
            ],
          ),
        ),
      ),
    );
  }
}
