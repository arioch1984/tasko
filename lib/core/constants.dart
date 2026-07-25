/// App-wide constants for Tasko.
abstract final class AppConstants {
  static const String appName = 'Tasko';
  /// Keep in sync with `pubspec.yaml` `version:` (before `+`).
  static const String version = '0.1.0';
  /// Keep in sync with `pubspec.yaml` build number (after `+`).
  static const int buildNumber = 1;
  static const String tasksScope = 'https://www.googleapis.com/auth/tasks';
  static const String tasksBaseUrl = 'https://tasks.googleapis.com/tasks/v1';
  static const String metaListTitle = '__Tasko';
  static const String metaConfigTaskTitle = 'Tasko Config';
  static const String packageName = 'com.tasko.tasko';

  static String get versionLabel => 'v$version ($buildNumber)';
}
