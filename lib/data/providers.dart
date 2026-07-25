import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasko/auth/auth_provider.dart';
import 'package:tasko/data/api/google_tasks_api.dart';
import 'package:tasko/data/repositories/tasks_repository.dart';
import 'package:tasko/domain/models.dart';

final googleTasksApiProvider = Provider<GoogleTasksApi>((ref) {
  final auth = ref.watch(authProvider.notifier);
  return GoogleTasksApi(getAccessToken: auth.accessToken);
});

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository(ref.watch(googleTasksApiProvider));
});

final taskListsProvider =
    FutureProvider.autoDispose<List<TaskList>>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isSignedIn) return [];
  return ref.watch(tasksRepositoryProvider).fetchLists();
});

final labelsProvider =
    FutureProvider.autoDispose<List<TaskLabel>>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isSignedIn) return [];
  return ref.watch(tasksRepositoryProvider).loadLabels();
});

final sortModeProvider = StateProvider<SortMode>((ref) => SortMode.dueDate);

final selectedLabelFilterProvider = StateProvider<String?>((ref) => null);

final celebrateTickProvider = StateProvider<int>((ref) => 0);

List<TaskItem> sortTasks(List<TaskItem> tasks, SortMode mode) {
  final copy = List<TaskItem>.from(tasks);
  switch (mode) {
    case SortMode.manual:
      copy.sort((a, b) => a.position.compareTo(b.position));
    case SortMode.dueDate:
      copy.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) {
          return a.position.compareTo(b.position);
        }
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        final byDue = a.dueDate!.compareTo(b.dueDate!);
        if (byDue != 0) return byDue;
        return a.priority.compareTo(b.priority);
      });
    case SortMode.priority:
      copy.sort((a, b) {
        final byP = a.priority.compareTo(b.priority);
        if (byP != 0) return byP;
        return a.position.compareTo(b.position);
      });
    case SortMode.title:
      copy.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
  }
  return copy;
}

List<TaskItem> filterByLabel(List<TaskItem> tasks, String? labelId) {
  if (labelId == null) return tasks;
  return tasks.where((t) => t.labelIds.contains(labelId)).toList();
}

final listTasksProvider =
    FutureProvider.autoDispose.family<List<TaskItem>, String>((ref, listId) {
  return ref.watch(tasksRepositoryProvider).fetchTasks(listId);
});

final allOpenTasksProvider =
    FutureProvider.autoDispose<List<TaskItem>>((ref) async {
  final lists = await ref.watch(taskListsProvider.future);
  final repo = ref.watch(tasksRepositoryProvider);
  final all = await repo.fetchAllTasks(lists);
  return all.where((t) => !t.isCompleted && !t.isSubtask).toList();
});

final todayTasksProvider =
    FutureProvider.autoDispose<List<TaskItem>>((ref) async {
  final all = await ref.watch(allOpenTasksProvider.future);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return all.where((t) {
    if (t.dueDate == null) return false;
    return !t.dueDate!.isAfter(today);
  }).toList();
});

final upcomingTasksProvider =
    FutureProvider.autoDispose<List<TaskItem>>((ref) async {
  final all = await ref.watch(allOpenTasksProvider.future);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final end = today.add(const Duration(days: 7));
  return all.where((t) {
    if (t.dueDate == null) return false;
    return t.dueDate!.isAfter(today) && !t.dueDate!.isAfter(end);
  }).toList();
});
