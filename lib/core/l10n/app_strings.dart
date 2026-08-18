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
  static const nothingUpcoming = 'No tasks in the next 7 days.';
  static const emptyList = 'Empty list. Add your first task!';

  // Errors
  static String listsError(Object e) => 'Lists error: $e';
  static String error(Object e) => 'Error: $e';
  static String saveFailed(Object e) => 'Save failed: $e';

  // Task detail
  static const newTask = 'New task';
  static const editTask = 'Edit task';
  static const save = 'Save';
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
