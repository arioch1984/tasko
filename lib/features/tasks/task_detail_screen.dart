import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tasko/core/dates.dart';
import 'package:tasko/core/l10n/app_strings.dart';
import 'package:tasko/core/reschedule_shortcuts_preference.dart';
import 'package:tasko/data/providers.dart';
import 'package:tasko/domain/models.dart';
import 'package:tasko/features/tasks/open_in_google_tasks_tile.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({
    super.key,
    required this.listId,
    required this.taskId,
  });

  final String? listId;
  final String? taskId;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  int _priority = 4;
  DateTime? _due;
  String? _listId;
  List<String> _labelIds = [];
  bool _loading = true;
  bool _saving = false;
  TaskItem? _existing;

  @override
  void initState() {
    super.initState();
    _listId = widget.listId;
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final lists = await ref.read(taskListsProvider.future);
    _listId ??= lists.isNotEmpty ? lists.first.id : null;

    if (widget.taskId != null && widget.listId != null) {
      final tasks =
          await ref.read(tasksRepositoryProvider).fetchTasks(widget.listId!);
      final task = tasks.where((t) => t.id == widget.taskId).firstOrNull;
      if (task != null) {
        _existing = task;
        _titleCtrl.text = task.title;
        _notesCtrl.text = task.notes;
        _priority = task.priority;
        _due = task.dueDate;
        _labelIds = List.of(task.labelIds);
        _listId = task.listId;
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _listId == null) return;
    setState(() => _saving = true);
    final repo = ref.read(tasksRepositoryProvider);
    try {
      if (_existing == null) {
        await repo.createTask(
          TaskItem(
            id: '',
            listId: _listId!,
            title: title,
            notes: _notesCtrl.text.trim(),
            dueDate: _due,
            priority: _priority,
            labelIds: _labelIds,
          ),
        );
      } else {
        await repo.updateTask(
          _existing!.copyWith(
            title: title,
            notes: _notesCtrl.text.trim(),
            dueDate: _due,
            clearDueDate: _due == null,
            priority: _priority,
            labelIds: _labelIds,
            listId: _listId,
          ),
        );
      }
      ref.invalidate(taskListsProvider);
      ref.invalidate(allOpenTasksProvider);
      if (_listId != null) ref.invalidate(listTasksProvider(_listId!));
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.saveFailed(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (_existing == null) return;
    await ref
        .read(tasksRepositoryProvider)
        .deleteTask(_existing!.listId, _existing!.id);
    ref.invalidate(listTasksProvider(_existing!.listId));
    ref.invalidate(allOpenTasksProvider);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final lists = ref.watch(taskListsProvider).valueOrNull ?? [];
    final labels = ref.watch(labelsProvider).valueOrNull ?? [];
    final isNew = widget.taskId == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? AppStrings.newTask : AppStrings.editTask),
        actions: [
          if (!isNew)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(AppStrings.save),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _titleCtrl,
                  autofocus: isNew,
                  decoration: const InputDecoration(
                    labelText: AppStrings.title,
                    hintText: AppStrings.titleHint,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesCtrl,
                  decoration: const InputDecoration(
                    labelText: AppStrings.notes,
                    alignLabelWithHint: true,
                  ),
                  minLines: 3,
                  maxLines: 6,
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.priority,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 1, label: Text('P1')),
                    ButtonSegment(value: 2, label: Text('P2')),
                    ButtonSegment(value: 3, label: Text('P3')),
                    ButtonSegment(value: 4, label: Text('P4')),
                  ],
                  selected: {_priority},
                  onSelectionChanged: (s) =>
                      setState(() => _priority = s.first),
                ),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(AppStrings.dueDate),
                  subtitle: Text(
                    _due == null
                        ? AppStrings.none
                        : '${_due!.day}/${_due!.month}/${_due!.year}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_due != null)
                        IconButton(
                          onPressed: () => setState(() => _due = null),
                          icon: const Icon(Icons.clear_rounded),
                        ),
                      IconButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _due ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _due = picked);
                          }
                        },
                        icon: const Icon(Icons.calendar_today_rounded),
                      ),
                    ],
                  ),
                ),
                if (_due != null && isOverdue(_due)) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final shortcut
                          in ref.watch(rescheduleShortcutsProvider))
                        ActionChip(
                          label: Text(shortcut.label),
                          onPressed: () =>
                              setState(() => _due = shortcut.resolve()),
                        ),
                    ],
                  ),
                ],
                if (_existing?.webViewLink != null) ...[
                  const SizedBox(height: 8),
                  OpenInGoogleTasksTile(webViewLink: _existing!.webViewLink!),
                ],
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _listId,
                  decoration: const InputDecoration(labelText: AppStrings.list),
                  items: lists
                      .map(
                        (l) => DropdownMenuItem(
                          value: l.id,
                          child: Text(l.title),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _listId = v),
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.labels,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (labels.isEmpty)
                  Text(
                    AppStrings.noLabelsHint,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: labels.map((label) {
                      final selected = _labelIds.contains(label.id);
                      return FilterChip(
                        selected: selected,
                        avatar: CircleAvatar(
                          backgroundColor: label.color,
                          radius: 8,
                        ),
                        label: Text(label.name),
                        onSelected: (v) {
                          setState(() {
                            if (v) {
                              _labelIds = [..._labelIds, label.id];
                            } else {
                              _labelIds = _labelIds
                                  .where((id) => id != label.id)
                                  .toList();
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.metadataFootnote,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      ),
                ),
              ],
            ),
    );
  }
}
