import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasko/auth/auth_provider.dart';
import 'package:tasko/core/dates.dart';
import 'package:tasko/core/today_layout_preference.dart';
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

final labelsProvider = FutureProvider.autoDispose<List<TaskLabel>>((ref) async {
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

List<TaskItem> tasksForToday(
  List<TaskItem> all,
  DateTime now, {
  required bool includeOverdue,
}) {
  final today = calendarToday(now);
  return all.where((t) {
    if (t.dueDate == null) return false;
    final due = calendarDay(t.dueDate!);
    if (includeOverdue) return !due.isAfter(today);
    return due == today;
  }).toList();
}

List<TaskItem> tasksOverdue(List<TaskItem> all, DateTime now) {
  return all.where((t) => isOverdue(t.dueDate, now)).toList();
}

List<TaskItem> tasksUpcoming(List<TaskItem> all, DateTime now) {
  final today = calendarToday(now);
  final end = today.add(const Duration(days: 7));
  return all.where((t) {
    if (t.dueDate == null) return false;
    final due = calendarDay(t.dueDate!);
    return due.isAfter(today) && !due.isAfter(end);
  }).toList();
}

final todayTasksProvider =
    FutureProvider.autoDispose<List<TaskItem>>((ref) async {
  final all = await ref.watch(allOpenTasksProvider.future);
  final includeOverdue = ref.watch(todayLayoutProvider) == TodayLayout.combined;
  return tasksForToday(
    all,
    DateTime.now(),
    includeOverdue: includeOverdue,
  );
});

final overdueTasksProvider =
    FutureProvider.autoDispose<List<TaskItem>>((ref) async {
  final all = await ref.watch(allOpenTasksProvider.future);
  return tasksOverdue(all, DateTime.now());
});

final upcomingTasksProvider =
    FutureProvider.autoDispose<List<TaskItem>>((ref) async {
  final all = await ref.watch(allOpenTasksProvider.future);
  return tasksUpcoming(all, DateTime.now());
});

void invalidateTaskCaches(
  void Function(ProviderOrFamily provider) invalidate, {
  Iterable<String> listIds = const [],
}) {
  invalidate(allOpenTasksProvider);
  invalidate(todayTasksProvider);
  invalidate(overdueTasksProvider);
  invalidate(upcomingTasksProvider);
  for (final listId in listIds) {
    invalidate(listTasksProvider(listId));
  }
}
