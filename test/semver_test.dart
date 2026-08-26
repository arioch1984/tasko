import 'package:flutter_test/flutter_test.dart';
import 'package:tasko/core/semver.dart';

void main() {
  test('parses v prefix and ignores build metadata', () {
    expect(Semver.tryParse('v0.4.2'), const Semver(0, 4, 2));
    expect(Semver.tryParse('0.4.2+9'), const Semver(0, 4, 2));
    expect(Semver.tryParse('1.2.3-beta.1'), const Semver(1, 2, 3));
  });

  test('rejects malformed versions', () {
    expect(Semver.tryParse(''), isNull);
    expect(Semver.tryParse('1.2'), isNull);
    expect(Semver.tryParse('nope'), isNull);
  });

  test('compares major.minor.patch', () {
    const current = Semver(0, 4, 2);
    expect(Semver.tryParse('0.4.3')!.isNewerThan(current), isTrue);
    expect(Semver.tryParse('0.5.0')!.isNewerThan(current), isTrue);
    expect(Semver.tryParse('1.0.0')!.isNewerThan(current), isTrue);
    expect(Semver.tryParse('0.4.2')!.isNewerThan(current), isFalse);
    expect(Semver.tryParse('0.4.1')!.isNewerThan(current), isFalse);
  });
}
