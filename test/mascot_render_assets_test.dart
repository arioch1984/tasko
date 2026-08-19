import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasko/core/mascot/tasko_painter.dart';
import 'package:tasko/core/mascot/tasko_pose.dart';

/// Regenerates mascot PNGs from [TaskoPainter].
///
///   RENDER_MASCOT=1 flutter test test/mascot_render_assets_test.dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const silhouette = Color(0xFF3A3530);
  const background = Color(0xFFF3E9D8);

  test('render mascot assets', () async {
    const poses = {
      TaskoPose.idle: 'assets/mascot/tasko_idle.png',
      TaskoPose.wave: 'assets/mascot/tasko_wave.png',
      TaskoPose.empty: 'assets/mascot/tasko_empty.png',
      TaskoPose.celebrate: 'assets/mascot/tasko_celebrate.png',
    };
    for (final entry in poses.entries) {
      await _writePng(entry.value, 1024, TaskoPainter(pose: entry.key));
    }

    await _writePng(
      'assets/brand/tasko_icon_source.png',
      1024,
      const TaskoPainter(pose: TaskoPose.idle),
    );

    await _writePng(
      'assets/icon/tasko_icon.png',
      1024,
      const TaskoPainter(
        pose: TaskoPose.idle,
        headOnly: true,
        monochrome: silhouette,
        headScale: 1.32,
      ),
      background: background,
    );

    const adaptive = {
      'mipmap-mdpi': 108,
      'mipmap-hdpi': 162,
      'mipmap-xhdpi': 216,
      'mipmap-xxhdpi': 324,
      'mipmap-xxxhdpi': 432,
    };
    const legacy = {
      'mipmap-mdpi': 48,
      'mipmap-hdpi': 72,
      'mipmap-xhdpi': 96,
      'mipmap-xxhdpi': 144,
      'mipmap-xxxhdpi': 192,
    };

    for (final entry in adaptive.entries) {
      await _writePng(
        'android/app/src/main/res/${entry.key}/ic_launcher_foreground.png',
        entry.value,
        const TaskoPainter(
          pose: TaskoPose.idle,
          headOnly: true,
          monochrome: silhouette,
          headScale: 1.2,
        ),
      );
    }
    for (final entry in legacy.entries) {
      await _writePng(
        'android/app/src/main/res/${entry.key}/ic_launcher.png',
        entry.value,
        const TaskoPainter(
          pose: TaskoPose.idle,
          headOnly: true,
          monochrome: silhouette,
          headScale: 1.28,
        ),
        background: background,
      );
    }

    const webIcon = TaskoPainter(
      pose: TaskoPose.idle,
      headOnly: true,
      monochrome: silhouette,
      headScale: 1.28,
    );
    const webMaskable = TaskoPainter(
      pose: TaskoPose.idle,
      headOnly: true,
      monochrome: silhouette,
      headScale: 1.0,
    );
    await _writePng('web/favicon.png', 32, webIcon, background: background);
    await _writePng('web/icons/Icon-192.png', 192, webIcon,
        background: background);
    await _writePng('web/icons/Icon-512.png', 512, webIcon,
        background: background);
    await _writePng(
      'web/icons/Icon-maskable-192.png',
      192,
      webMaskable,
      background: background,
    );
    await _writePng(
      'web/icons/Icon-maskable-512.png',
      512,
      webMaskable,
      background: background,
    );
  },
      skip: Platform.environment['RENDER_MASCOT'] == '1'
          ? false
          : 'Set RENDER_MASCOT=1 to regenerate rasters.');
}

Future<void> _writePng(
  String path,
  int size,
  CustomPainter painter, {
  Color? background,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  if (background != null) {
    canvas.drawColor(background, BlendMode.src);
  }
  painter.paint(canvas, Size(size.toDouble(), size.toDouble()));
  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}
