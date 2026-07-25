import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tasko/auth/auth_provider.dart';
import 'package:tasko/core/constants.dart';
import 'package:tasko/core/l10n/app_strings.dart';
import 'package:tasko/core/mascot/tasko_mascot.dart';
import 'package:tasko/core/mascot/tasko_pose.dart';
import 'package:tasko/core/theme.dart';
import 'package:tasko/data/providers.dart';
import 'package:tasko/domain/models.dart';
import 'package:tasko/features/tasks/task_tile.dart';

enum HomeView { today, upcoming, list }

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

  @override
  Widget build(BuildContext context) {
    final listsAsync = ref.watch(taskListsProvider);
    final labelsAsync = ref.watch(labelsProvider);
    final sortMode = ref.watch(sortModeProvider);
    final labelFilter = ref.watch(selectedLabelFilterProvider);

    ref.listen(celebrateTickProvider, (prev, next) {
      if (prev != next && next > 0) {
        setState(() => _showCelebrate = true);
        Future.delayed(const Duration(milliseconds: 1400), () {
          if (mounted) setState(() => _showCelebrate = false);
        });
      }
    });

    final title = switch (_view) {
      HomeView.today => AppStrings.today,
      HomeView.upcoming => AppStrings.upcoming,
      HomeView.list => _listTitle ?? AppStrings.list,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
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
      ),
      drawer: Drawer(
        backgroundColor: TaskoColors.cream,
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
                  setState(() {
                    _view = HomeView.today;
                    _listId = null;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.upcoming_rounded),
                title: const Text(AppStrings.upcoming),
                selected: _view == HomeView.upcoming,
                onTap: () {
                  setState(() {
                    _view = HomeView.upcoming;
                    _listId = null;
                  });
                  Navigator.pop(context);
                },
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(AppStrings.lists, style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: TaskoColors.warmGrey,
                  letterSpacing: 0.6,
                )),
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
                        selected:
                            _view == HomeView.list && _listId == list.id,
                        onTap: () {
                          setState(() {
                            _view = HomeView.list;
                            _listId = list.id;
                            _listTitle = list.title;
                          });
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
                  setState(() {
                    _view = HomeView.list;
                    _listId = list.id;
                    _listTitle = list.title;
                  });
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
      floatingActionButton: FloatingActionButton(
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
                                    .read(
                                        selectedLabelFilterProvider.notifier)
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
              Expanded(child: _buildBody(sortMode, labelFilter)),
            ],
          ),
          if (_showCelebrate)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: TaskoColors.mist.withValues(alpha: 0.55),
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

  Widget _buildBody(SortMode sortMode, String? labelFilter) {
    return switch (_view) {
      HomeView.today => _SmartListBody(
          provider: todayTasksProvider,
          emptyMessage: AppStrings.nothingDueToday,
          sortMode: sortMode,
          labelFilter: labelFilter,
        ),
      HomeView.upcoming => _SmartListBody(
          provider: upcomingTasksProvider,
          emptyMessage: AppStrings.nothingUpcoming,
          sortMode: sortMode,
          labelFilter: labelFilter,
        ),
      HomeView.list => _listId == null
          ? const Center(child: Text(AppStrings.selectAList))
          : _ListBody(
              listId: _listId!,
              sortMode: sortMode,
              labelFilter: labelFilter,
            ),
    };
  }
}

class _SmartListBody extends ConsumerWidget {
  const _SmartListBody({
    required this.provider,
    required this.emptyMessage,
    required this.sortMode,
    required this.labelFilter,
  });

  final ProviderListenable<AsyncValue<List<TaskItem>>> provider;
  final String emptyMessage;
  final SortMode sortMode;
  final String? labelFilter;

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
            ref.invalidate(todayTasksProvider);
            ref.invalidate(upcomingTasksProvider);
            ref.invalidate(allOpenTasksProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: visible.length,
            itemBuilder: (context, index) {
              return TaskTile(task: visible[index], labels: labels);
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
  });

  final String listId;
  final SortMode sortMode;
  final String? labelFilter;

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
              return TaskTile(task: visible[index], labels: labels);
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
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(due.year, due.month, due.day);
  if (d == today) return AppStrings.today;
  if (d == today.add(const Duration(days: 1))) return AppStrings.tomorrow;
  if (d == today.subtract(const Duration(days: 1))) {
    return AppStrings.yesterday;
  }
  return DateFormat('MMM d', 'en_US').format(due);
}
