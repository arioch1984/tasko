import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasko/core/monday_material_localizations.dart';
import 'package:tasko/core/router.dart';
import 'package:tasko/core/theme.dart';
import 'package:tasko/core/theme_preference.dart';

class TaskoApp extends ConsumerWidget {
  const TaskoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themePreference = ref.watch(themePreferenceProvider);
    return MaterialApp.router(
      title: 'Tasko',
      debugShowCheckedModeBanner: false,
      theme: taskoLightTheme,
      darkTheme: taskoDarkTheme,
      themeMode: themePreference.themeMode,
      localizationsDelegates: const [
        MondayMaterialLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
