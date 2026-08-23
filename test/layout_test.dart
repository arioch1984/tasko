import 'package:flutter_test/flutter_test.dart';
import 'package:tasko/core/layout.dart';

void main() {
  test('useDesktopNav is false below the breakpoint', () {
    expect(useDesktopNav(kDesktopNavBreakpoint - 1), isFalse);
  });

  test('useDesktopNav is true at and above the breakpoint', () {
    expect(useDesktopNav(kDesktopNavBreakpoint), isTrue);
    expect(useDesktopNav(1200), isTrue);
  });
}
