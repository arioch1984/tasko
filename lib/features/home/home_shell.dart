import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tasko/auth/auth_provider.dart';
import 'package:tasko/core/constants.dart';
import 'package:tasko/core/dates.dart';
import 'package:tasko/core/l10n/app_strings.dart';
import 'package:tasko/core/mascot/tasko_mascot.dart';
import 'package:tasko/core/mascot/tasko_pose.dart';
import 'package:tasko/core/reschedule_shortcuts_preference.dart';
import 'package:tasko/core/theme_preference.dart';
import 'package:tasko/core/today_layout_preference.dart';
import 'package:tasko/data/providers.dart';
import 'package:tasko/domain/models.dart';
import 'package:tasko/features/settings/appearance_dialog.dart';
import 'package:tasko/features/tasks/reschedule_sheet.dart';
import 'package:tasko/features/tasks/task_tile.dart';

enum HomeView { today, overdue, upcoming, list }

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  HomeView _view = HomeView.today;
  String? _listId;
  String? _listTitle;
  bool _showCelebrate = false;
  bool _selecting = false;
  final Map<String, TaskItem> _selected = {};

  String _taskKey(TaskItem task) => '${task.listId}/${task.id}';

  void _clearSelection() {
    setState(() {
      _selecting = false;
      _selected.clear();
    });
  }

  void _openView(HomeView view, {String? listId, String? listTitle}) {
    setState(() {
      _view = view;
      if (view == HomeView.list) {
        _listId = listId;
        if (listTitle != null) _listTitle = listTitle;
      } else {
        _listId = null;
      }
      _selecting = false;
      _selected.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final listsAsync = ref.watch(taskListsProvider);
    final labelsAsync = ref.watch(labelsProvider);
    final sortMode = ref.watch(sortModeProvider);
    final labelFilter = ref.watch(selectedLabelFilterProvider);
    final themePreference = ref.watch(themePreferenceProvider);
    final todayLayout = ref.watch(todayLayoutProvider);
    final splitToday = todayLayout == TodayLayout.split;

    ref.listen(celebrateTickProvider, (prev, next) {
      if (prev != next && next > 0) {
        setState(() => _showCelebrate = true);
        Future.delayed(const Duration(milliseconds: 1400), () {
          if (mounted) setState(() => _showCelebrate = false);
        });
      }
    });

    ref.listen(todayLayoutProvider, (prev, next) {
      if (next == TodayLayout.combined && _view == HomeView.overdue) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _openView(HomeView.today);
        });
      }
    });

    final title = _selecting
        ? AppStrings.selectedCount(_selected.length)
        : switch (_view) {
            HomeView.today => AppStrings.today,
            HomeView.overdue => AppStrings.overdue,
            HomeView.upcoming => AppStrings.upcoming,
            HomeView.list => _listTitle ?? AppStrings.list,
          };

    final overdueInView = switch (_view) {
      HomeView.today => (ref.watch(todayTasksProvider).valueOrNull ?? [])
          .any((t) => isOverdue(t.dueDate)),
      HomeView.overdue =>
        (ref.watch(overdueTasksProvider).valueOrNull ?? []).isNotEmpty,
      _ => false,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (_selecting) ...[
            IconButton(
              tooltip: AppStrings.reschedule,
              onPressed: _selected.isEmpty ? null : _rescheduleSelected,
              icon: const Icon(Icons.event_repeat_rounded),
            ),
            IconButton(
              tooltip: AppStrings.done,
              onPressed: _clearSelection,
              icon: const Icon(Icons.close_rounded),
            ),
          ] else ...[
            if (overdueInView)
              IconButton(
                tooltip: AppStrings.selectOverdue,
                onPressed: () => setState(() => _selecting = true),
                icon: const Icon(Icons.checklist_rounded),
              ),
            PopupMenuButton<SortMode>(
              tooltip: AppStrings.sort,
              icon: const Icon(Icons.sort_rounded),
              initialValue: sortMode,
              onSelected: (mode) {
                ref.read(sortModeProvider.notifier).state = mode;
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: SortMode.dueDate,
                  child: Text(AppStrings.dueDate),
                ),
                PopupMenuItem(
                  value: SortMode.priority,
                  child: Text(AppStrings.priority),
                ),
                PopupMenuItem(
                  value: SortMode.title,
                  child: Text(AppStrings.title),
                ),
                PopupMenuItem(
                  value: SortMode.manual,
                  child: Text(AppStrings.manual),
                ),
              ],
            ),
          ],
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Image.asset(
                      TaskoPose.idle.assetPath,
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.today_rounded),
                title: const Text(AppStrings.today),
                selected: _view == HomeView.today,
                onTap: () {
                  _openView(HomeView.today);
                  Navigator.pop(context);
                },
              ),
              if (splitToday)
                ListTile(
                  leading: const Icon(Icons.event_busy_rounded),
                  title: const Text(AppStrings.overdue),
                  selected: _view == HomeView.overdue,
                  onTap: () {
                    _openView(HomeView.overdue);
                    Navigator.pop(context);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.upcoming_rounded),
                title: const Text(AppStrings.upcoming),
                selected: _view == HomeView.upcoming,
                onTap: () {
                  _openView(HomeView.upcoming);
                  Navigator.pop(context);
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  AppStrings.lists,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                ),
              ),
              Expanded(
                child: listsAsync.when(
                  data: (lists) => ListView.builder(
                    itemCount: lists.length,
                    itemBuilder: (context, index) {
                      final list = lists[index];
                      return ListTile(
                        leading: const Icon(Icons.list_alt_rounded),
                        title: Text(list.title),
                        selected: _view == HomeView.list && _listId == list.id,
                        onTap: () {
                          _openView(
                            HomeView.list,
                            listId: list.id,
                            listTitle: list.title,
                          );
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(AppStrings.listsError(e)),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add_box_outlined),
                title: const Text(AppStrings.newList),
                onTap: () async {
                  Navigator.pop(context);
                  final controller = TextEditingController();
                  final name = await showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text(AppStrings.newList),
                      content: TextField(
                        controller: controller,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: AppStrings.listName,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(AppStrings.cancel),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.pop(context, controller.text.trim()),
                          child: const Text(AppStrings.create),
                        ),
                      ],
                    ),
                  );
                  if (name == null || name.isEmpty) return;
                  final list =
                      await ref.read(tasksRepositoryProvider).createList(name);
                  ref.invalidate(taskListsProvider);
                  _openView(
                    HomeView.list,
                    listId: list.id,
                    listTitle: list.title,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.label_outline_rounded),
                title: const Text(AppStrings.labels),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/labels');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text(AppStrings.settings),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/settings');
                },
              ),
              ListTile(
                leading: Icon(themePreference.icon),
                title: const Text(AppStrings.appearance),
                subtitle: Text(
                  AppStrings.themePreferenceLabel(themePreference),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  if (!context.mounted) return;
                  await showAppearanceDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text(AppStrings.signOut),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(authProvider.notifier).signOut();
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _selecting
          ? null
          : FloatingActionButton(
              onPressed: () {
                final q = _listId != null ? '?listId=$_listId' : '';
                context.push('/task/new$q');
              },
              child: const Icon(Icons.add_rounded),
            ),
      body: Stack(
        children: [
          Column(
            children: [
              labelsAsync.maybeWhen(
                data: (labels) {
                  if (labels.isEmpty) return const SizedBox.shrink();
                  return SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text(AppStrings.all),
                            selected: labelFilter == null,
                            onSelected: (_) {
                              ref
                                  .read(selectedLabelFilterProvider.notifier)
                                  .state = null;
                            },
                          ),
                        ),
                        ...labels.map(
                          (label) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              avatar: CircleAvatar(
                                backgroundColor: label.color,
                                radius: 8,
                              ),
                              label: Text(label.name),
                              selected: labelFilter == label.id,
                              onSelected: (_) {
                                ref
                                    .read(selectedLabelFilterProvider.notifier)
                                    .state = label.id;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),
              Expanded(
                child: _buildBody(sortMode, labelFilter),
              ),
            ],
          ),
          if (_showCelebrate)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: Theme.of(context)
                      .scaffoldBackgroundColor
                      .withValues(alpha: 0.55),
                  child: const Center(
                    child: TaskoMascot(
                      pose: TaskoPose.celebrate,
                      size: 180,
                      message: AppStrings.niceWork,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _rescheduleSelected() async {
    final tasks = _selected.values.toList();
    if (tasks.isEmpty) return;
    final shortcuts = ref.read(rescheduleShortcutsProvider);
    final due = await showRescheduleSheet(
      context: context,
      shortcuts: shortcuts,
      taskCount: tasks.length,
    );
    if (due == null || !mounted) return;
    try {
      await ref.read(tasksRepositoryProvider).rescheduleTasks(tasks, due);
      invalidateTaskCaches(
        ref.invalidate,
        listIds: tasks.map((t) => t.listId),
      );
      if (!mounted) return;
      _clearSelection();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.rescheduledCount(tasks.length))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.rescheduleFailed)),
      );
    }
  }

  Widget _buildBody(SortMode sortMode, String? labelFilter) {
    final selection = (
      selecting: _selecting,
      selectedIds: _selected.keys.toSet(),
      onToggle: (TaskItem task) {
        if (!isOverdue(task.dueDate)) return;
        setState(() {
          final key = _taskKey(task);
          if (_selected.containsKey(key)) {
            _selected.remove(key);
          } else {
            _selected[key] = task;
          }
        });
      },
    );

    return switch (_view) {
      HomeView.today => _SmartListBody(
          provider: todayTasksProvider,
          emptyMessage: AppStrings.nothingDueToday,
          sortMode: sortMode,
          labelFilter: labelFilter,
          selection: selection,
        ),
      HomeView.overdue => _SmartListBody(
          provider: overdueTasksProvider,
          emptyMessage: AppStrings.nothingOverdue,
          sortMode: sortMode,
          labelFilter: labelFilter,
          selection: selection,
        ),
      HomeView.upcoming => _SmartListBody(
          provider: upcomingTasksProvider,
          emptyMessage: AppStrings.nothingUpcoming,
          sortMode: sortMode,
          labelFilter: labelFilter,
          selection: selection,
        ),
      HomeView.list => _listId == null
          ? const Center(child: Text(AppStrings.selectAList))
          : _ListBody(
              listId: _listId!,
              sortMode: sortMode,
              labelFilter: labelFilter,
              selection: selection,
            ),
    };
  }
}

typedef _TaskSelection = ({
  bool selecting,
  Set<String> selectedIds,
  void Function(TaskItem task) onToggle,
});

class _SmartListBody extends ConsumerWidget {
  const _SmartListBody({
    required this.provider,
    required this.emptyMessage,
    required this.sortMode,
    required this.labelFilter,
    required this.selection,
  });

  final ProviderListenable<AsyncValue<List<TaskItem>>> provider;
  final String emptyMessage;
  final SortMode sortMode;
  final String? labelFilter;
  final _TaskSelection selection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(provider);
    final labels = ref.watch(labelsProvider).valueOrNull ?? [];

    return async.when(
      data: (tasks) {
        final visible = sortTasks(filterByLabel(tasks, labelFilter), sortMode);
        if (visible.isEmpty) {
          return Center(
            child: TaskoMascot(
              pose: TaskoPose.empty,
              size: 180,
              message: emptyMessage,
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            invalidateTaskCaches(ref.invalidate);
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: visible.length,
            itemBuilder: (context, index) {
              final task = visible[index];
              final key = '${task.listId}/${task.id}';
              return TaskTile(
                task: task,
                labels: labels,
                selecting: selection.selecting,
                selected: selection.selectedIds.contains(key),
                onToggleSelect: () => selection.onToggle(task),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(AppStrings.error(e))),
    );
  }
}

class _ListBody extends ConsumerWidget {
  const _ListBody({
    required this.listId,
    required this.sortMode,
    required this.labelFilter,
    required this.selection,
  });

  final String listId;
  final SortMode sortMode;
  final String? labelFilter;
  final _TaskSelection selection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(listTasksProvider(listId));
    final labels = ref.watch(labelsProvider).valueOrNull ?? [];

    return async.when(
      data: (tasks) {
        final open = tasks.where((t) => !t.isCompleted && !t.isSubtask);
        final visible =
            sortTasks(filterByLabel(open.toList(), labelFilter), sortMode);
        if (visible.isEmpty) {
          return const Center(
            child: TaskoMascot(
              pose: TaskoPose.empty,
              size: 180,
              message: AppStrings.emptyList,
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(listTasksProvider(listId)),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: visible.length,
            itemBuilder: (context, index) {
              final task = visible[index];
              final key = '${task.listId}/${task.id}';
              return TaskTile(
                task: task,
                labels: labels,
                selecting: selection.selecting,
                selected: selection.selectedIds.contains(key),
                onToggleSelect: () => selection.onToggle(task),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(AppStrings.error(e))),
    );
  }
}

String formatDue(DateTime? due) {
  if (due == null) return '';
  final today = calendarToday();
  final d = calendarDay(due);
  if (d == today) return AppStrings.today;
  if (d == today.add(const Duration(days: 1))) return AppStrings.tomorrow;
  if (d == today.subtract(const Duration(days: 1))) {
    return AppStrings.yesterday;
  }
  return DateFormat('MMM d', 'en_US').format(due);
}
