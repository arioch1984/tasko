import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasko/core/constants.dart';
import 'package:tasko/core/semver.dart';
import 'package:tasko/core/theme_preference.dart';
import 'package:tasko/core/update_check_store.dart';
import 'package:tasko/data/api/github_releases_api.dart';
import 'package:tasko/domain/github_release.dart';

sealed class UpdateCheckOutcome {
  const UpdateCheckOutcome();
}

class UpdateCheckIdle extends UpdateCheckOutcome {
  const UpdateCheckIdle();
}

class UpdateCheckUpToDate extends UpdateCheckOutcome {
  const UpdateCheckUpToDate();
}

class UpdateCheckAvailable extends UpdateCheckOutcome {
  const UpdateCheckAvailable(this.release);

  final GithubRelease release;
}

class UpdateCheckSkipped extends UpdateCheckOutcome {
  const UpdateCheckSkipped();
}

class UpdateCheckFailed extends UpdateCheckOutcome {
  const UpdateCheckFailed([this.error]);

  final Object? error;
}

class AppUpdateController {
  AppUpdateController({
    required GithubReleasesClient api,
    required UpdateCheckStore store,
    required String currentVersion,
    DateTime Function()? clock,
    Duration failureCooldown = const Duration(minutes: 15),
  })  : _api = api,
        _store = store,
        _currentVersion = currentVersion,
        _clock = clock ?? DateTime.now,
        _failureCooldown = failureCooldown;

  final GithubReleasesClient _api;
  final UpdateCheckStore _store;
  final String _currentVersion;
  final DateTime Function() _clock;
  final Duration _failureCooldown;
  DateTime? _lastFailedAttempt;

  Future<UpdateCheckOutcome>? _inFlightAuto;

  Future<UpdateCheckOutcome> autoCheck() async {
    final existing = _inFlightAuto;
    if (existing != null) return existing;
    final future = _runAutoCheck();
    _inFlightAuto = future;
    try {
      return await future;
    } finally {
      if (identical(_inFlightAuto, future)) {
        _inFlightAuto = null;
      }
    }
  }

  Future<UpdateCheckOutcome> _runAutoCheck() async {
    final now = _clock();
    if (!_store.shouldAutoCheck(now)) return const UpdateCheckIdle();
    if (_lastFailedAttempt != null &&
        now.difference(_lastFailedAttempt!) < _failureCooldown) {
      return const UpdateCheckIdle();
    }
    try {
      final latest = await _api.fetchLatest();
      await _store.markChecked(now);
      _lastFailedAttempt = null;
      return compare(latest, respectSkip: true);
    } catch (e) {
      _lastFailedAttempt = now;
      return const UpdateCheckIdle();
    }
  }

  Future<UpdateCheckOutcome> manualCheck() async {
    final now = _clock();
    try {
      final latest = await _api.fetchLatest();
      await _store.markChecked(now);
      _lastFailedAttempt = null;
      return compare(latest, respectSkip: false);
    } catch (e) {
      _lastFailedAttempt = now;
      return UpdateCheckFailed(e);
    }
  }

  Future<void> skip(String version) => _store.skipVersion(version);

  @visibleForTesting
  UpdateCheckOutcome compare(
    GithubRelease latest, {
    required bool respectSkip,
  }) {
    final current = Semver.tryParse(_currentVersion);
    final remote = Semver.tryParse(latest.version);
    if (current == null || remote == null) {
      return const UpdateCheckFailed('Invalid version');
    }
    if (!remote.isNewerThan(current)) return const UpdateCheckUpToDate();
    if (respectSkip && _store.isSkipped(latest.version)) {
      return const UpdateCheckSkipped();
    }
    return UpdateCheckAvailable(latest);
  }
}

final githubReleasesClientProvider = Provider<GithubReleasesClient>((ref) {
  return GithubReleasesApi();
});

final updateCheckStoreProvider = Provider<UpdateCheckStore>((ref) {
  return UpdateCheckStore(ref.watch(sharedPreferencesProvider));
});

final appUpdateControllerProvider = Provider<AppUpdateController>((ref) {
  return AppUpdateController(
    api: ref.watch(githubReleasesClientProvider),
    store: ref.watch(updateCheckStoreProvider),
    currentVersion: AppConstants.version,
  );
});
