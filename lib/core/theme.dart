import 'package:flutter/material.dart';

/// Brand palette derived from Tasko the badger: warm greys + teal accent.
abstract final class TaskoColors {
  static const Color teal = Color(0xFF2A9D8F);
  static const Color tealDark = Color(0xFF1D7A6F);
  static const Color amber = Color(0xFFE9A825);
  static const Color charcoal = Color(0xFF2C2A28);
  static const Color warmGrey = Color(0xFF6B6560);
  static const Color mist = Color(0xFFF3F0EB);
  static const Color mistDeep = Color(0xFFE6E1D8);
  static const Color cream = Color(0xFFFAF8F4);
  static const Color stripe = Color(0xFF1A1816);
  static const Color danger = Color(0xFFC45C4A);

  static const List<Color> labelPalette = [
    Color(0xFF2A9D8F),
    Color(0xFFE9A825),
    Color(0xFFC45C4A),
    Color(0xFF4A7FC4),
    Color(0xFF8B6BB5),
    Color(0xFF5C8A4A),
    Color(0xFFD47A3A),
    Color(0xFF5A6A7A),
  ];
}

ThemeData buildTaskoTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: TaskoColors.teal,
    brightness: Brightness.light,
    primary: TaskoColors.teal,
    onPrimary: Colors.white,
    secondary: TaskoColors.amber,
    surface: TaskoColors.cream,
    onSurface: TaskoColors.charcoal,
    error: TaskoColors.danger,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: TaskoColors.mist,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: TaskoColors.cream,
      foregroundColor: TaskoColors.charcoal,
      elevation: 0,
      scrolledUnderElevation: 0.5,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: TaskoColors.teal,
      foregroundColor: Colors.white,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: TaskoColors.mistDeep,
      selectedColor: TaskoColors.teal.withValues(alpha: 0.2),
      labelStyle: const TextStyle(color: TaskoColors.charcoal),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: TaskoColors.cream,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: TaskoColors.mistDeep),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: TaskoColors.mistDeep),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: TaskoColors.teal, width: 1.5),
      ),
    ),
    dividerTheme: const DividerThemeData(color: TaskoColors.mistDeep),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: TaskoColors.charcoal,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w600,
        color: TaskoColors.charcoal,
      ),
      bodyLarge: TextStyle(color: TaskoColors.charcoal),
      bodyMedium: TextStyle(color: TaskoColors.warmGrey),
    ),
  );
}
