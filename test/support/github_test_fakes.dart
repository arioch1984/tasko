import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasko/core/constants.dart';
import 'package:tasko/core/theme_preference.dart';
import 'package:tasko/data/api/github_releases_api.dart';
import 'package:tasko/domain/github_release.dart';
import 'package:tasko/features/update/app_update_controller.dart';

export 'package:tasko/data/api/github_releases_api.dart' show GithubReleasesClient;

class SilentGithubReleasesClient implements GithubReleasesClient {
  const SilentGithubReleasesClient();

  @override
  Future<GithubRelease> fetchLatest() async {
    return GithubRelease(
      version: AppConstants.version,
      tagName: 'v${AppConstants.version}',
      htmlUrl: AppConstants.githubReleasesUrl,
    );
  }
}

class ScriptedGithubReleasesClient implements GithubReleasesClient {
  const ScriptedGithubReleasesClient(this.release);

  final GithubRelease release;

  @override
  Future<GithubRelease> fetchLatest() async => release;
}

/// Always newer than [AppConstants.version], so update-dialog tests survive
/// a release bump (the old `0.5.0` fixture matched v0.5.0 and hid the dialog).
GithubRelease newerThanInstalledRelease({String notes = 'Fresh build'}) {
  return GithubRelease(
    version: '99.0.0',
    tagName: 'v99.0.0',
    htmlUrl: 'https://github.com/arioch1984/tasko/releases/tag/v99.0.0',
    notes: notes,
  );
}

List<Override> taskoTestOverrides(
  SharedPreferences prefs, {
  GithubReleasesClient? github,
}) {
  return [
    sharedPreferencesProvider.overrideWithValue(prefs),
    githubReleasesClientProvider.overrideWithValue(
      github ?? const SilentGithubReleasesClient(),
    ),
  ];
}
