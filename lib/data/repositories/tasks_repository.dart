import 'dart:convert';

import 'package:tasko/core/constants.dart';
import 'package:tasko/core/theme.dart';
import 'package:tasko/data/api/google_tasks_api.dart';
import 'package:tasko/data/codec/tasko_metadata_codec.dart';
import 'package:tasko/domain/models.dart';

class TasksRepository {
  TasksRepository(this._api);

  final GoogleTasksApi _api;

  String? _metaListId;
  String? _metaConfigTaskId;

  TaskList _mapList(Map<String, dynamic> json) {
    return TaskList(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
    );
  }

  TaskItem _mapTask(Map<String, dynamic> json, String listId) {
    return taskItemFromGoogleJson(json, listId);
  }

  Map<String, dynamic> _taskBody(TaskItem task) {
    final notes = TaskoMetadataCodec.encode(
      priority: task.priority,
      labelIds: task.labelIds,
      notes: task.notes,
    );
    return {
      'title': task.title,
      if (notes.isNotEmpty) 'notes': notes,
      if (notes.isEmpty) 'notes': '',
      'status':
          task.status == TaskStatus.completed ? 'completed' : 'needsAction',
      if (task.dueDate != null)
        'due': DateTime.utc(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        ).toIso8601String(),
    };
  }

  Future<List<TaskList>> fetchLists({bool includeMeta = false}) async {
    final raw = await _api.listTaskLists();
    final lists = raw.map(_mapList).toList();
    if (includeMeta) return lists;
    return lists.where((l) => !l.isMeta).toList();
  }

  Future<TaskList> createList(String title) async {
    final json = await _api.insertTaskList(title);
    return _mapList(json);
  }

  Future<void> deleteList(String listId) => _api.deleteTaskList(listId);

  Future<List<TaskItem>> fetchTasks(String listId) async {
    final raw = await _api.listTasks(listId);
    return raw.map((e) => _mapTask(e, listId)).toList();
  }

  Future<List<TaskItem>> fetchAllTasks(List<TaskList> lists) async {
    final all = <TaskItem>[];
    for (final list in lists) {
      all.addAll(await fetchTasks(list.id));
    }
    return all;
  }

  Future<TaskItem> createTask(TaskItem task) async {
    final json = await _api.insertTask(
      task.listId,
      _taskBody(task),
      parent: task.parentId,
    );
    return _mapTask(json, task.listId);
  }

  Future<TaskItem> updateTask(TaskItem task) async {
    final body = _taskBody(task);
    // Clearing due date requires sending null — patch with due omitted keeps it.
    // Google Tasks API: omit due to keep; to clear, we need special handling.
    if (task.dueDate == null) {
      body['due'] = null;
    }
    final json = await _api.patchTask(task.listId, task.id, body);
    return _mapTask(json, task.listId);
  }

  Future<void> deleteTask(String listId, String taskId) {
    return _api.deleteTask(listId, taskId);
  }

  Future<TaskItem> toggleCompleted(TaskItem task) {
    return updateTask(
      task.copyWith(
        status:
            task.isCompleted ? TaskStatus.needsAction : TaskStatus.completed,
      ),
    );
  }

  Future<void> rescheduleTasks(List<TaskItem> tasks, DateTime dueDate) async {
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    for (final task in tasks) {
      await updateTask(task.copyWith(dueDate: due));
    }
  }

  Future<void> ensureMetaList() async {
    final lists = await fetchLists(includeMeta: true);
    final existing = lists.where((l) => l.isMeta).firstOrNull;
    if (existing != null) {
      _metaListId = existing.id;
    } else {
      final created = await createList(AppConstants.metaListTitle);
      _metaListId = created.id;
    }

    final tasks = await fetchTasks(_metaListId!);
    final config = tasks
        .where((t) => t.title == AppConstants.metaConfigTaskTitle)
        .firstOrNull;
    if (config != null) {
      _metaConfigTaskId = config.id;
    } else {
      final created = await _api.insertTask(_metaListId!, {
        'title': AppConstants.metaConfigTaskTitle,
        'notes': jsonEncode({'labels': <Map<String, dynamic>>[]}),
      });
      _metaConfigTaskId = created['id'] as String;
    }
  }

  Future<List<TaskLabel>> loadLabels() async {
    await ensureMetaList();
    final tasks = await _api.listTasks(_metaListId!);
    final config = tasks.cast<Map<String, dynamic>?>().firstWhere(
          (t) => t?['title'] == AppConstants.metaConfigTaskTitle,
          orElse: () => null,
        );
    if (config == null) return [];
    _metaConfigTaskId = config['id'] as String;
    final notes = config['notes'] as String? ?? '{}';
    try {
      final json = jsonDecode(notes) as Map<String, dynamic>;
      final labels = json['labels'] as List? ?? [];
      return labels
          .map((e) => TaskLabel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<TaskLabel>> saveLabels(List<TaskLabel> labels) async {
    await ensureMetaList();
    final notes = jsonEncode({
      'labels': labels.map((l) => l.toJson()).toList(),
    });
    await _api.patchTask(_metaListId!, _metaConfigTaskId!, {
      'title': AppConstants.metaConfigTaskTitle,
      'notes': notes,
    });
    return labels;
  }

  Future<List<TaskLabel>> upsertLabel(TaskLabel label) async {
    final labels = await loadLabels();
    final index = labels.indexWhere((l) => l.id == label.id);
    if (index >= 0) {
      labels[index] = label;
    } else {
      labels.add(label);
    }
    return saveLabels(labels);
  }

  Future<List<TaskLabel>> deleteLabel(String labelId) async {
    final labels = await loadLabels();
    labels.removeWhere((l) => l.id == labelId);
    return saveLabels(labels);
  }

  TaskLabel createDefaultLabel(String name) {
    final id = name
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    final color = TaskoColors
        .labelPalette[name.hashCode.abs() % TaskoColors.labelPalette.length];
    return TaskLabel(
      id: id.isEmpty ? 'label-${DateTime.now().millisecondsSinceEpoch}' : id,
      name: name.trim(),
      colorValue: color.toARGB32(),
    );
  }
}

TaskItem taskItemFromGoogleJson(Map<String, dynamic> json, String listId) {
  final decoded = TaskoMetadataCodec.decode(json['notes'] as String?);
  DateTime? due;
  final dueRaw = json['due'] as String?;
  if (dueRaw != null) {
    due = DateTime.tryParse(dueRaw)?.toLocal();
    if (due != null) {
      due = DateTime(due.year, due.month, due.day);
    }
  }
  DateTime? updated;
  final updatedRaw = json['updated'] as String?;
  if (updatedRaw != null) {
    updated = DateTime.tryParse(updatedRaw)?.toLocal();
  }
  final webViewLink = json['webViewLink'] as String?;

  return TaskItem(
    id: json['id'] as String,
    listId: listId,
    title: json['title'] as String? ?? '',
    notes: decoded.notes,
    dueDate: due,
    status: json['status'] == 'completed'
        ? TaskStatus.completed
        : TaskStatus.needsAction,
    parentId: json['parent'] as String?,
    position: json['position'] as String? ?? '',
    priority: decoded.priority,
    labelIds: decoded.labelIds,
    updated: updated,
    webViewLink: (webViewLink == null || webViewLink.isEmpty)
        ? null
        : webViewLink,
  );
}
