import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasko/core/mascot/tasko_mascot.dart';
import 'package:tasko/core/mascot/tasko_painter.dart';
import 'package:tasko/core/mascot/tasko_pose.dart';
import 'package:tasko/core/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('painter repaints when pose or tint changes', () {
    const idle = TaskoPainter(pose: TaskoPose.idle);
    expect(
        idle.shouldRepaint(const TaskoPainter(pose: TaskoPose.wave)), isTrue);
    expect(
      idle.shouldRepaint(const TaskoPainter(pose: TaskoPose.idle)),
      isFalse,
    );
    expect(
      const TaskoPainter(pose: TaskoPose.idle, headOnly: true)
          .shouldRepaint(const TaskoPainter(pose: TaskoPose.idle)),
      isTrue,
    );
  });

  testWidgets('TaskoMascot and TaskoMark build for every pose', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              TaskoMascot(pose: TaskoPose.idle, size: 80),
              TaskoMascot(pose: TaskoPose.wave, size: 80),
              TaskoMascot(pose: TaskoPose.empty, size: 80),
              TaskoMascot(
                pose: TaskoPose.celebrate,
                size: 80,
                message: 'Nice',
              ),
              TaskoMark(size: 32),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(TaskoMascot), findsNWidgets(4));
    expect(find.byType(TaskoMark), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.text('Nice'), findsOneWidget);
  });

  testWidgets('TaskoMark follows onSurface in dark theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: taskoDarkTheme,
        home: const Scaffold(body: Center(child: TaskoMark(size: 40))),
      ),
    );
    final paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(TaskoMark),
        matching: find.byType(CustomPaint),
      ),
    );
    final painter = paint.painter! as TaskoPainter;
    expect(painter.headOnly, isTrue);
    expect(painter.monochrome, isNotNull);
    expect(
      ThemeData.estimateBrightnessForColor(painter.monochrome!),
      Brightness.light,
    );
  });
}
