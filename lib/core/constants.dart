/// App-wide constants for Tasko.
abstract final class AppConstants {
  static const String appName = 'Tasko';

  /// Keep in sync with `pubspec.yaml` `version:` (before `+`).
  static const String version = '0.4.2';

  /// Keep in sync with `pubspec.yaml` build number (after `+`).
  static const int buildNumber = 9;
  static const String tasksScope = 'https://www.googleapis.com/auth/tasks';
  static const String tasksBaseUrl = 'https://tasks.googleapis.com/tasks/v1';
  static const String metaListTitle = '__Tasko';
  static const String metaConfigTaskTitle = 'Tasko Config';
  static const String packageName = 'com.tasko.tasko';

  /// iOS-type OAuth client ID for macOS Google Sign-In (public, not a secret).
  /// Create in GCP: Credentials → OAuth client ID → iOS, bundle ID [packageName].
  /// Pass at build time with `--dart-define=TASKO_MACOS_GOOGLE_CLIENT_ID=...`
  /// or paste a default here after the client exists.
  static const String macosGoogleClientId = String.fromEnvironment(
    'TASKO_MACOS_GOOGLE_CLIENT_ID',
    defaultValue:
        '504670274514-iqbr5550g5ic5a1kc0kfte6ttl51ql7f.apps.googleusercontent.com',
  );

  static String get versionLabel => 'v$version ($buildNumber)';
}
