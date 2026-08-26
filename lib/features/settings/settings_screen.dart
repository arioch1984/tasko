import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasko/core/constants.dart';
import 'package:tasko/core/l10n/app_strings.dart';
import 'package:tasko/core/reschedule_shortcuts_preference.dart';
import 'package:tasko/core/today_layout_preference.dart';
import 'package:tasko/domain/reschedule_shortcut.dart';
import 'package:tasko/features/settings/appearance_dialog.dart';
import 'package:tasko/features/update/app_update_controller.dart';
import 'package:tasko/features/update/present_update_check.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(todayLayoutProvider);
    final shortcuts = ref.watch(rescheduleShortcutsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text(AppStrings.appearance),
            onTap: () => showAppearanceDialog(context),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              AppStrings.about,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(AppConstants.versionLabel),
          ),
          const _CheckForUpdatesTile(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              AppStrings.todayLayout,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ListTile(
            title: const Text(AppStrings.todayLayoutCombined),
            subtitle: const Text(AppStrings.todayLayoutCombinedHint),
            selected: layout == TodayLayout.combined,
            trailing: layout == TodayLayout.combined
                ? const Icon(Icons.check_rounded)
                : null,
            onTap: () {
              ref
                  .read(todayLayoutProvider.notifier)
                  .setLayout(TodayLayout.combined);
            },
          ),
          ListTile(
            title: const Text(AppStrings.todayLayoutSplit),
            subtitle: const Text(AppStrings.todayLayoutSplitHint),
            selected: layout == TodayLayout.split,
            trailing: layout == TodayLayout.split
                ? const Icon(Icons.check_rounded)
                : null,
            onTap: () {
              ref
                  .read(todayLayoutProvider.notifier)
                  .setLayout(TodayLayout.split);
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              AppStrings.rescheduleShortcuts,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              AppStrings.rescheduleShortcutsHint,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shortcuts.length,
            onReorderItem: (oldIndex, newIndex) {
              ref
                  .read(rescheduleShortcutsProvider.notifier)
                  .reorder(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final shortcut = shortcuts[index];
              return ListTile(
                key: ValueKey(shortcut.id),
                leading: const Icon(Icons.drag_handle_rounded),
                title: Text(shortcut.label),
                trailing: IconButton(
                  tooltip: AppStrings.delete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () {
                    ref
                        .read(rescheduleShortcutsProvider.notifier)
                        .remove(shortcut.id);
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_rounded),
            title: const Text(AppStrings.addShortcut),
            onTap: () => _addShortcut(context, ref),
          ),
        ],
      ),
    );
  }
}

class _CheckForUpdatesTile extends ConsumerStatefulWidget {
  const _CheckForUpdatesTile();

  @override
  ConsumerState<_CheckForUpdatesTile> createState() =>
      _CheckForUpdatesTileState();
}

class _CheckForUpdatesTileState extends ConsumerState<_CheckForUpdatesTile> {
  bool _checking = false;

  Future<void> _check() async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      final outcome =
          await ref.read(appUpdateControllerProvider).manualCheck();
      if (!mounted) return;
      await presentUpdateCheckOutcome(context, ref, outcome, manual: true);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.system_update_alt_rounded),
      title: const Text(AppStrings.checkForUpdates),
      subtitle: _checking ? const Text(AppStrings.checkingForUpdates) : null,
      enabled: !_checking,
      onTap: _check,
    );
  }
}

Future<void> _addShortcut(BuildContext context, WidgetRef ref) async {
  final notifier = ref.read(rescheduleShortcutsProvider.notifier);
  final existing = ref.read(rescheduleShortcutsProvider);

  if (existing.length >= RescheduleShortcutsNotifier.maxShortcuts) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.shortcutLimitReached)),
    );
    return;
  }

  final kind = await showModalBottomSheet<RescheduleKind>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final hasTomorrow =
          existing.any((s) => s.kind == RescheduleKind.tomorrow);
      final hasNextWeek =
          existing.any((s) => s.kind == RescheduleKind.nextWeek);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                enabled: !hasTomorrow,
                leading: const Icon(Icons.wb_sunny_outlined),
                title: const Text(AppStrings.tomorrow),
                subtitle: const Text(AppStrings.shortcutTomorrowHint),
                onTap: hasTomorrow
                    ? null
                    : () => Navigator.pop(context, RescheduleKind.tomorrow),
              ),
              ListTile(
                enabled: !hasNextWeek,
                leading: const Icon(Icons.next_week_outlined),
                title: const Text(AppStrings.nextWeek),
                subtitle: const Text(AppStrings.shortcutNextWeekHint),
                onTap: hasNextWeek
                    ? null
                    : () => Navigator.pop(context, RescheduleKind.nextWeek),
              ),
              ListTile(
                leading: const Icon(Icons.more_time_rounded),
                title: const Text(AppStrings.shortcutInDays),
                subtitle: const Text(AppStrings.shortcutInDaysHint),
                onTap: () => Navigator.pop(context, RescheduleKind.inDays),
              ),
              ListTile(
                leading: const Icon(Icons.date_range_rounded),
                title: const Text(AppStrings.shortcutNextWeekday),
                subtitle: const Text(AppStrings.shortcutNextWeekdayHint),
                onTap: () => Navigator.pop(context, RescheduleKind.nextWeekday),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (kind == null || !context.mounted) return;

  RescheduleShortcut? shortcut;
  switch (kind) {
    case RescheduleKind.tomorrow:
      shortcut = RescheduleShortcut(
        id: 'tomorrow-${DateTime.now().millisecondsSinceEpoch}',
        kind: RescheduleKind.tomorrow,
      );
    case RescheduleKind.nextWeek:
      shortcut = RescheduleShortcut(
        id: 'nextWeek-${DateTime.now().millisecondsSinceEpoch}',
        kind: RescheduleKind.nextWeek,
      );
    case RescheduleKind.inDays:
      final days = await _pickDayCount(context);
      if (days == null) return;
      shortcut = RescheduleShortcut(
        id: 'inDays-$days-${DateTime.now().millisecondsSinceEpoch}',
        kind: RescheduleKind.inDays,
        dayCount: days,
      );
    case RescheduleKind.nextWeekday:
      final weekday = await _pickWeekday(context);
      if (weekday == null) return;
      shortcut = RescheduleShortcut(
        id: 'weekday-$weekday-${DateTime.now().millisecondsSinceEpoch}',
        kind: RescheduleKind.nextWeekday,
        weekday: weekday,
      );
  }

  final added = await notifier.add(shortcut);
  if (!added && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.shortcutAlreadyAdded)),
    );
  }
}

Future<int?> _pickDayCount(BuildContext context) {
  return showDialog<int>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(AppStrings.howManyDays),
        content: SizedBox(
          width: 320,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var n = 1; n <= 14; n++)
                ActionChip(
                  label: Text('$n'),
                  onPressed: () => Navigator.pop(context, n),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
        ],
      );
    },
  );
}

Future<int?> _pickWeekday(BuildContext context) {
  return showDialog<int>(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: const Text(AppStrings.chooseWeekday),
        children: [
          for (var day = DateTime.monday; day <= DateTime.sunday; day++)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, day),
              child: Text(AppStrings.weekdayName(day)),
            ),
        ],
      );
    },
  );
}
