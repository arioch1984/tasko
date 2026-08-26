import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasko/core/update_check_store.dart';
import 'package:tasko/data/api/github_releases_api.dart';
import 'package:tasko/domain/github_release.dart';
import 'package:tasko/features/update/app_update_controller.dart';

class _FakeGithub implements GithubReleasesClient {
  _FakeGithub(this.release);

  GithubRelease release;
  Object? error;
  int fetches = 0;

  @override
  Future<GithubRelease> fetchLatest() async {
    fetches++;
    final err = error;
    if (err != null) throw err;
    return release;
  }
}

GithubRelease _release(String version) {
  return GithubRelease(
    version: version,
    tagName: 'v$version',
    htmlUrl: 'https://github.com/arioch1984/tasko/releases/tag/v$version',
  );
}

void main() {
  late SharedPreferences prefs;
  late UpdateCheckStore store;
  late _FakeGithub api;
  late DateTime now;
  late AppUpdateController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    store = UpdateCheckStore(prefs);
    api = _FakeGithub(_release('0.5.0'));
    now = DateTime(2026, 8, 26, 8);
    controller = AppUpdateController(
      api: api,
      store: store,
      currentVersion: '0.4.2',
      clock: () => now,
    );
  });

  test('autoCheck offers a newer release once per 24 hours', () async {
    final first = await controller.autoCheck();
    expect(first, isA<UpdateCheckAvailable>());
    expect((first as UpdateCheckAvailable).release.version, '0.5.0');
    expect(api.fetches, 1);

    final again = await controller.autoCheck();
    expect(again, isA<UpdateCheckIdle>());
    expect(api.fetches, 1);

    now = now.add(const Duration(hours: 24));
    final nextDay = await controller.autoCheck();
    expect(nextDay, isA<UpdateCheckAvailable>());
    expect(api.fetches, 2);
  });

  test('autoCheck respects skip; manual check still offers the update', () async {
    await controller.skip('0.5.0');
    final auto = await controller.autoCheck();
    expect(auto, isA<UpdateCheckSkipped>());

    now = now.add(const Duration(hours: 24));
    final manual = await controller.manualCheck();
    expect(manual, isA<UpdateCheckAvailable>());
  });

  test('same version is up to date', () async {
    api.release = _release('0.4.2');
    final outcome = await controller.manualCheck();
    expect(outcome, isA<UpdateCheckUpToDate>());
  });

  test('autoCheck stays silent on errors; manualCheck reports them', () async {
    api.error = Exception('offline');
    expect(await controller.autoCheck(), isA<UpdateCheckIdle>());
    expect(await controller.manualCheck(), isA<UpdateCheckFailed>());
  });

  test('autoCheck does not retry immediately after a failure', () async {
    api.error = Exception('offline');
    await controller.autoCheck();
    expect(api.fetches, 1);
    await controller.autoCheck();
    expect(api.fetches, 1);

    now = now.add(const Duration(minutes: 15));
    await controller.autoCheck();
    expect(api.fetches, 2);
  });
}
