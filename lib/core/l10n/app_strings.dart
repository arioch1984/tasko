import 'package:tasko/core/theme_preference.dart';

/// English UI copy for Tasko.
///
/// Primary language is English. Full localization (ARB / flutter_gen) can be
/// wired later by replacing these constants with generated getters — keep
/// call sites on [AppStrings] so migration stays mechanical.
class AppStrings {
  AppStrings._();

  // Home / navigation
  static const today = 'Today';
  static const overdue = 'Overdue';
  static const upcoming = 'Upcoming';
  static const list = 'List';
  static const lists = 'LISTS';
  static const sort = 'Sort';
  static const dueDate = 'Due date';
  static const priority = 'Priority';
  static const title = 'Title';
  static const manual = 'Manual';
  static const newList = 'New list';
  static const listName = 'List name';
  static const cancel = 'Cancel';
  static const create = 'Create';
  static const labels = 'Labels';
  static const signOut = 'Sign out';
  static const settings = 'Settings';
  static const appearance = 'Appearance';
  static const themeSystem = 'System default';
  static const themeLight = 'Light';
  static const themeDark = 'Dark';
  static const themeSystemHint = 'Match the device setting';
  static const done = 'Done';
  static const all = 'All';
  static const selectAList = 'Select a list';

  static String themePreferenceLabel(ThemePreference preference) =>
      switch (preference) {
        ThemePreference.system => themeSystem,
        ThemePreference.light => themeLight,
        ThemePreference.dark => themeDark,
      };

  // Empty / celebrate
  static const niceWork = 'Nice work!';
  static const nothingDueToday = 'Nothing due today. Tasko is all set.';
  static const nothingOverdue = 'Nothing overdue. Tasko is caught up.';
  static const nothingUpcoming = 'No tasks in the next 7 days.';
  static const emptyList = 'Empty list. Add your first task!';

  // Settings — Today layout
  static const todayLayout = 'Today and overdue';
  static const todayLayoutCombined = 'Together on Today';
  static const todayLayoutCombinedHint =
      'Today shows tasks due today and anything already overdue.';
  static const todayLayoutSplit = 'Separate Overdue item';
  static const todayLayoutSplitHint =
      'Today shows only today. Overdue tasks get their own drawer item.';

  // Settings — reschedule shortcuts
  static const reschedule = 'Reschedule';
  static const rescheduleShortcuts = 'Reschedule shortcuts';
  static const rescheduleShortcutsHint =
      'Quick due dates for overdue tasks. Used one at a time or in bulk.';
  static const addShortcut = 'Add shortcut';
  static const pickADate = 'Pick a date';
  static const nextWeek = 'Next week';
  static const shortcutTomorrowHint = 'Move the due date to tomorrow.';
  static const shortcutNextWeekHint = 'Move the due date 7 days from today.';
  static const shortcutInDays = 'In a few days';
  static const shortcutInDaysHint = 'Choose how many days from today.';
  static const shortcutNextWeekday = 'Next weekday';
  static const shortcutNextWeekdayHint =
      'Jump to the next Monday, Tuesday, and so on.';
  static const howManyDays = 'How many days?';
  static const chooseWeekday = 'Choose a weekday';
  static const shortcutAlreadyAdded = 'That shortcut is already in the list.';
  static const shortcutLimitReached = 'You can keep up to 8 shortcuts.';
  static const selectOverdue = 'Select overdue';
  static const rescheduleFailed = 'Could not reschedule. Try again.';

  static String inDays(int n) => n == 1 ? 'In 1 day' : 'In $n days';

  static String nextWeekday(int weekday) => 'Next ${weekdayName(weekday)}';

  static String weekdayName(int weekday) => switch (weekday) {
        DateTime.monday => 'Monday',
        DateTime.tuesday => 'Tuesday',
        DateTime.wednesday => 'Wednesday',
        DateTime.thursday => 'Thursday',
        DateTime.friday => 'Friday',
        DateTime.saturday => 'Saturday',
        DateTime.sunday => 'Sunday',
        _ => 'day',
      };

  static String selectedCount(int n) => n == 1 ? '1 selected' : '$n selected';

  static String rescheduledCount(int n) =>
      n == 1 ? 'Rescheduled 1 task' : 'Rescheduled $n tasks';

  static String rescheduleCount(int n) =>
      n == 1 ? 'Reschedule 1 task' : 'Reschedule $n tasks';

  // Errors
  static String listsError(Object e) => 'Lists error: $e';
  static String error(Object e) => 'Error: $e';
  static String saveFailed(Object e) => 'Save failed: $e';

  // Task detail
  static const newTask = 'New task';
  static const editTask = 'Edit task';
  static const save = 'Save';
  static const delete = 'Delete';
  static const titleHint = 'What needs doing?';
  static const notes = 'Notes';
  static const none = 'None';
  static const noLabelsHint =
      'No labels yet. Create one from the Labels section.';
  static const metadataFootnote =
      'Priority and labels are stored in Google Tasks notes '
      'inside a Tasko block that stays hidden in this app.';

  // Labels screen
  static const noLabelsTapPlus = 'No labels yet. Tap + to create one.';
  static const newLabel = 'New label';
  static const editLabel = 'Edit label';
  static const name = 'Name';

  // Sign-in
  static const signInTagline =
      'Google Tasks, with priority, labels, and room to breathe.';
  static const continueWithGoogle = 'Continue with Google';
  static const signingIn = 'Signing in…';
  static const signInFootnote =
      'Your tasks stay on Google Tasks.\nTasko is just the interface.';

  // Dates
  static const tomorrow = 'Tomorrow';
  static const yesterday = 'Yesterday';
}
