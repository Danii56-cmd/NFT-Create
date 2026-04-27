import 'package:flutter/material.dart';
import 'package:nft_create/enums.dart';
import 'package:nft_create/models/drawing_point.dart';
import 'package:nft_create/models/shape_item.dart';

class DrawingPainter extends CustomPainter {
  final List<List<DrawingPoint?>> strokes;
  final List<DrawingPoint?> currentStroke;
  final List<ShapeItem> shapes;

  DrawingPainter({
    required this.strokes,
    required this.currentStroke,
    required this.shapes,
<<<<<<< HEAD
    // required BlendMode blendMode,
=======
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
    _drawStroke(canvas, currentStroke);
    for (final shape in shapes) {
      _drawShape(canvas, shape);
    }
  }

  void _drawStroke(Canvas canvas, List<DrawingPoint?> stroke) {
    for (int i = 0; i < stroke.length - 1; i++) {
      if (stroke[i] != null && stroke[i + 1] != null) {
        canvas.drawLine(
          stroke[i]!.offset,
          stroke[i + 1]!.offset,
          stroke[i]!.paint,
        );
      } else if (stroke[i] != null) {
        canvas.drawCircle(
          stroke[i]!.offset,
          stroke[i]!.paint.strokeWidth / 2,
          stroke[i]!.paint,
        );
      }
    }
  }

  void _drawShape(Canvas canvas, ShapeItem s) {
    final paint = Paint()
      ..color = s.color
      ..strokeWidth = s.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromPoints(s.start, s.end);

    switch (s.type) {
      case ShapeType.rectangle:
        canvas.drawRect(rect, paint);
        break;
      case ShapeType.circle:
        canvas.drawOval(rect, paint);
        break;
      case ShapeType.line:
        canvas.drawLine(s.start, s.end, paint);
        break;
      case ShapeType.triangle:
        final path = Path()
          ..moveTo((s.start.dx + s.end.dx) / 2, s.start.dy)
          ..lineTo(s.end.dx, s.end.dy)
          ..lineTo(s.start.dx, s.end.dy)
          ..close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(DrawingPainter old) => true;
}
