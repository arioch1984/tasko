import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasko/core/router.dart';
import 'package:tasko/core/theme.dart';

class TaskoApp extends ConsumerWidget {
  const TaskoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Tasko',
      debugShowCheckedModeBanner: false,
      theme: buildTaskoTheme(),
      routerConfig: router,
    );
  }
}
