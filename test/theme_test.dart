import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasko/core/theme.dart';

void main() {
  test('light theme uses cream surfaces and mist scaffold', () {
    final theme = buildTaskoTheme();
    expect(theme.brightness, Brightness.light);
    expect(theme.scaffoldBackgroundColor, TaskoColors.mist);
    expect(theme.colorScheme.surface, TaskoColors.cream);
    expect(theme.colorScheme.primary, TaskoColors.teal);
  });

  test('dark theme uses night surfaces and brighter teal', () {
    final theme = buildTaskoTheme(brightness: Brightness.dark);
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, TaskoColors.night);
    expect(theme.colorScheme.surface, TaskoColors.nightSurface);
    expect(theme.colorScheme.primary, TaskoColors.tealBright);
    expect(theme.colorScheme.onSurface, TaskoColors.mist);
  });

  test('exported light and dark themes match builders', () {
    expect(taskoLightTheme.brightness, Brightness.light);
    expect(taskoDarkTheme.brightness, Brightness.dark);
  });

  test('sign-in gradient follows brightness', () {
    expect(
      signInGradientColors(Brightness.light).first,
      TaskoColors.cream,
    );
    expect(
      signInGradientColors(Brightness.dark).first,
      TaskoColors.night,
    );
  });
}
