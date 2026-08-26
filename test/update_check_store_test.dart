import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasko/core/update_check_store.dart';

void main() {
  late SharedPreferences prefs;
  late UpdateCheckStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    store = UpdateCheckStore(prefs);
  });

  test('auto-checks when never checked', () {
    expect(store.shouldAutoCheck(DateTime(2026, 8, 26, 8)), isTrue);
  });

  test('waits 24 hours after a successful check', () async {
    final now = DateTime(2026, 8, 26, 8);
    await store.markChecked(now);
    expect(store.shouldAutoCheck(now.add(const Duration(hours: 23))), isFalse);
    expect(store.shouldAutoCheck(now.add(const Duration(hours: 24))), isTrue);
  });

  test('remembers a skipped version', () async {
    expect(store.isSkipped('0.5.0'), isFalse);
    await store.skipVersion('0.5.0');
    expect(store.isSkipped('0.5.0'), isTrue);
    expect(store.isSkipped('0.5.1'), isFalse);
  });
}
