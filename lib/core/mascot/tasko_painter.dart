import 'package:flutter/material.dart';
import 'package:tasko/core/mascot/tasko_pose.dart';
import 'package:tasko/core/theme.dart';

/// Flat geometric Tasko, in the same language as Capy Reader's mascot:
/// chunky rounded shapes, solid fills, no outlines or shading.
class TaskoPainter extends CustomPainter {
  const TaskoPainter({
    required this.pose,
    this.monochrome,
    this.headOnly = false,
    this.headScale = 1.42,
  });

  final TaskoPose pose;
  final Color? monochrome;

  /// Launcher / drawer mark: just the side-profile head.
  final bool headOnly;

  /// Scale of the head when [headOnly] is true. Lower values add
  /// adaptive-icon padding.
  final double headScale;

  bool get _silhouetted => monochrome != null;

  Color get _fur => _c(const Color(0xFF7A7671));
  Color get _furDark => _c(const Color(0xFF4E4A46));
  Color get _stripe => _c(TaskoColors.stripe);
  Color get _face => _c(const Color(0xFFF7F4EF));
  Color get _teal => _c(TaskoColors.teal);
  Color get _board => _c(const Color(0xFFEDE8E0));
  Color get _line => _c(const Color(0xFFC4BDB4));

  Color _c(Color color) => monochrome ?? color;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    canvas.save();
    canvas.translate(
      (size.width - side) / 2,
      (size.height - side) / 2,
    );
    canvas.scale(side / 100);

    if (headOnly) {
      canvas.save();
      canvas.translate(50, 52);
      canvas.scale(headScale);
      canvas.translate(-36, -24);
      _paintHead(canvas, details: !_silhouetted);
      canvas.restore();
    } else {
      switch (pose) {
        case TaskoPose.idle:
          _paintIdle(canvas);
        case TaskoPose.wave:
          _paintWave(canvas);
        case TaskoPose.empty:
          _paintEmpty(canvas);
        case TaskoPose.celebrate:
          _paintCelebrate(canvas);
      }
    }

    canvas.restore();
  }

  void _paintIdle(Canvas canvas) {
    _paintBoard(canvas, const Rect.fromLTWH(70, 36, 22, 46), checks: 3);
    _paintBody(canvas, sit: true, origin: const Offset(8, 50));
    canvas.save();
    canvas.translate(18, 24);
    _paintHead(canvas, details: !_silhouetted);
    canvas.restore();
  }

  void _paintWave(Canvas canvas) {
    _paintBoard(canvas, const Rect.fromLTWH(56, 50, 18, 34), checks: 3);
    _paintLimb(canvas, const Offset(46, 48), const Offset(64, 20), 10);
    _paintBody(canvas, sit: false, origin: const Offset(14, 48));
    canvas.save();
    canvas.translate(16, 16);
    _paintHead(canvas, details: !_silhouetted);
    canvas.restore();
  }

  void _paintEmpty(Canvas canvas) {
    _paintBoard(canvas, const Rect.fromLTWH(70, 36, 22, 46), checks: 0);
    _paintBody(canvas, sit: true, origin: const Offset(8, 50));
    _paintLimb(canvas, const Offset(48, 50), const Offset(58, 40), 9);
    canvas.save();
    canvas.translate(14, 22);
    _paintHead(canvas, details: !_silhouetted);
    canvas.restore();
  }

  void _paintCelebrate(Canvas canvas) {
    _paintSparks(canvas);
    _paintBoard(
      canvas,
      const Rect.fromLTWH(66, 42, 20, 32),
      checks: 0,
      bigCheck: true,
    );
    _paintLimb(canvas, const Offset(44, 42), const Offset(56, 14), 10);
    _paintBody(canvas, sit: false, origin: const Offset(12, 42));
    canvas.save();
    canvas.translate(16, 10);
    _paintHead(canvas, details: !_silhouetted);
    canvas.restore();
  }

  void _paintSparks(Canvas canvas) {
    if (_silhouetted) return;
    final paint = Paint()..color = _teal;
    void spark(Offset at, double rot, double len) {
      canvas.save();
      canvas.translate(at.dx, at.dy);
      canvas.rotate(rot);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 2.4, height: len),
          const Radius.circular(1.2),
        ),
        paint,
      );
      canvas.restore();
    }

    spark(const Offset(74, 16), -0.55, 13);
    spark(const Offset(82, 22), 0.25, 11);
    spark(const Offset(88, 14), 0.95, 9);
  }

  void _paintBody(
    Canvas canvas, {
    required bool sit,
    required Offset origin,
  }) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);

    if (sit) {
      _fillOval(canvas, const Rect.fromLTWH(0, 0, 52, 40), _fur);
      _fillOval(canvas, const Rect.fromLTWH(-6, 14, 16, 13), _fur);
      _fillOval(canvas, const Rect.fromLTWH(6, 28, 18, 16), _furDark);
      _fillOval(canvas, const Rect.fromLTWH(30, 28, 18, 16), _furDark);
    } else {
      _fillRRect(canvas, const Rect.fromLTWH(4, 0, 40, 46), 19, _fur);
      _fillOval(canvas, const Rect.fromLTWH(-6, 18, 16, 13), _fur);
      _fillOval(canvas, const Rect.fromLTWH(8, 38, 16, 14), _furDark);
      _fillOval(canvas, const Rect.fromLTWH(28, 38, 16, 14), _furDark);
    }

    canvas.restore();
  }

  void _paintLimb(Canvas canvas, Offset from, Offset to, double width) {
    canvas.drawLine(
      from,
      to,
      Paint()
        ..color = _furDark
        ..strokeCap = StrokeCap.round
        ..strokeWidth = width
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(to, width * 0.58, Paint()..color = _furDark);
  }

  /// Side-profile head in a ~62x42 local box, facing right.
  void _paintHead(Canvas canvas, {required bool details}) {
    final silhouette = _headPath();
    canvas.drawPath(silhouette, Paint()..color = _fur);
    canvas.drawPath(_earPath(), Paint()..color = _furDark);

    if (!details) return;

    canvas.save();
    canvas.clipPath(silhouette);
    _fillRRect(canvas, const Rect.fromLTWH(24, 8, 30, 12), 6, _face);
    _fillRRect(canvas, const Rect.fromLTWH(32, 22, 24, 13), 6.5, _face);
    _fillRRect(canvas, const Rect.fromLTWH(16, 14, 28, 12), 6, _stripe);
    canvas.restore();

    canvas.drawCircle(const Offset(42, 23.5), 1.7, Paint()..color = _stripe);
    _fillRRect(canvas, const Rect.fromLTWH(54.5, 25.2, 6.2, 4.6), 2, _stripe);
    canvas.drawPath(_earInnerPath(), Paint()..color = _face);
  }

  Path _earPath() {
    return Path()
      ..addOval(Rect.fromCircle(center: const Offset(16, 9), radius: 6.8));
  }

  Path _earInnerPath() {
    return Path()
      ..addOval(Rect.fromCircle(center: const Offset(16.6, 9.6), radius: 3.4));
  }

  Path _headPath() {
    final path = Path();
    path.moveTo(10, 22);
    path.cubicTo(9, 12, 16, 7, 26, 8);
    path.cubicTo(40, 5, 52, 11, 59, 20);
    path.cubicTo(63, 25, 63.5, 31, 59, 35);
    path.cubicTo(52, 41, 36, 43, 22, 38);
    path.cubicTo(10, 34, 7, 28, 10, 22);
    path.close();
    path.addPath(_earPath(), Offset.zero);
    return path;
  }

  void _paintBoard(
    Canvas canvas,
    Rect rect, {
    required int checks,
    bool bigCheck = false,
  }) {
    _fillRRect(canvas, rect, 4, _board);
    _fillRRect(
      canvas,
      Rect.fromLTWH(rect.left, rect.top, rect.width, 6.5),
      3.2,
      _furDark,
    );

    if (bigCheck) {
      final box = Rect.fromCenter(
        center: Offset(rect.center.dx, rect.center.dy + 3),
        width: 13,
        height: 13,
      );
      _fillRRect(canvas, box, 3, _teal);
      _strokeCheck(canvas, box, 2.1);
      return;
    }

    final top = rect.top + 12;
    final gap = (rect.height - 20) / 3;
    for (var i = 0; i < 3; i++) {
      final y = top + gap * i;
      final box = Rect.fromLTWH(rect.left + 3.5, y, 6, 6);
      if (i < checks) {
        _fillRRect(canvas, box, 1.3, _teal);
        _strokeCheck(canvas, box, 1.25);
      } else {
        _fillRRect(canvas, box, 1.3, _line);
      }
      _fillRRect(
        canvas,
        Rect.fromLTWH(rect.left + 12, y + 1.8, rect.width - 16.5, 2.2),
        1.1,
        _line,
      );
    }
  }

  void _strokeCheck(Canvas canvas, Rect box, double width) {
    final path = Path()
      ..moveTo(box.left + box.width * 0.22, box.center.dy)
      ..lineTo(box.left + box.width * 0.42, box.bottom - box.height * 0.24)
      ..lineTo(box.right - box.width * 0.2, box.top + box.height * 0.24);
    canvas.drawPath(
      path,
      Paint()
        ..color = _face
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _fillOval(Canvas canvas, Rect rect, Color color) {
    canvas.drawOval(rect, Paint()..color = color);
  }

  void _fillRRect(Canvas canvas, Rect rect, double radius, Color color) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant TaskoPainter oldDelegate) {
    return oldDelegate.pose != pose ||
        oldDelegate.monochrome != monochrome ||
        oldDelegate.headOnly != headOnly ||
        oldDelegate.headScale != headScale;
  }
}
