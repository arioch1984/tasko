import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Brand palette derived from Tasko the badger: warm greys + teal accent.
abstract final class TaskoColors {
  static const Color teal = Color(0xFF2A9D8F);
  static const Color tealDark = Color(0xFF1D7A6F);
  static const Color tealBright = Color(0xFF3CB8A9);
  static const Color amber = Color(0xFFE9A825);
  static const Color charcoal = Color(0xFF2C2A28);
  static const Color warmGrey = Color(0xFF6B6560);
  static const Color warmGreyLight = Color(0xFFB8B0A8);
  static const Color mist = Color(0xFFF3F0EB);
  static const Color mistDeep = Color(0xFFE6E1D8);
  static const Color cream = Color(0xFFFAF8F4);
  static const Color stripe = Color(0xFF1A1816);
  static const Color danger = Color(0xFFC45C4A);

  static const Color night = Color(0xFF161412);
  static const Color nightSurface = Color(0xFF1F1C1A);
  static const Color nightElevated = Color(0xFF2A2724);
  static const Color nightBorder = Color(0xFF3A3632);
  static const Color signInMint = Color(0xFFD9EDE9);
  static const Color signInMintDark = Color(0xFF1A2E2B);

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

ThemeData buildTaskoTheme({Brightness brightness = Brightness.light}) {
  final isDark = brightness == Brightness.dark;
  final onSurface = isDark ? TaskoColors.mist : TaskoColors.charcoal;
  final muted = isDark ? TaskoColors.warmGreyLight : TaskoColors.warmGrey;
  final scaffold = isDark ? TaskoColors.night : TaskoColors.mist;
  final surface = isDark ? TaskoColors.nightSurface : TaskoColors.cream;
  final border = isDark ? TaskoColors.nightBorder : TaskoColors.mistDeep;
  final inputFill = isDark ? TaskoColors.nightElevated : TaskoColors.cream;
  final chipBg = isDark ? TaskoColors.nightElevated : TaskoColors.mistDeep;
  final primary = isDark ? TaskoColors.tealBright : TaskoColors.teal;

  final colorScheme = ColorScheme.fromSeed(
    seedColor: TaskoColors.teal,
    brightness: brightness,
    primary: primary,
    onPrimary: isDark ? TaskoColors.night : Colors.white,
    secondary: TaskoColors.amber,
    surface: surface,
    onSurface: onSurface,
    error: TaskoColors.danger,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: scaffold,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: surface,
      foregroundColor: onSurface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    ),
    drawerTheme: DrawerThemeData(backgroundColor: surface),
    dialogTheme: DialogThemeData(backgroundColor: surface),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: isDark ? TaskoColors.night : Colors.white,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: chipBg,
      selectedColor: primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(color: onSurface),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
    ),
    dividerTheme: DividerThemeData(color: border),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: onSurface,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: TextStyle(color: onSurface),
      bodyMedium: TextStyle(color: muted),
    ),
  );
}

final ThemeData taskoLightTheme = buildTaskoTheme();
final ThemeData taskoDarkTheme = buildTaskoTheme(brightness: Brightness.dark);

List<Color> signInGradientColors(Brightness brightness) {
  if (brightness == Brightness.dark) {
    return const [
      TaskoColors.night,
      TaskoColors.nightSurface,
      TaskoColors.signInMintDark,
    ];
  }
  return const [
    TaskoColors.cream,
    TaskoColors.mist,
    TaskoColors.signInMint,
  ];
}
