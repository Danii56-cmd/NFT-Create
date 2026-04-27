// ─────────────────────────────────────────────────────────────────────────────
// noise_painter.dart
// Draws a film-grain / noise overlay on top of the canvas.
// Uses a fixed random seed so the pattern is stable across repaints;
// only repaints when intensity or seed actually changes.
// Wrapped in RepaintBoundary so dragging the grain slider doesn't
// invalidate the stroke or background layers.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/material.dart';

class NoisePainter extends CustomPainter {
  final double intensity; // 0.0 – 1.0
  final int seed;

  const NoisePainter({required this.intensity, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;

    final rng = math.Random(seed);
    final paint = Paint();
    // Number of dots scales with canvas area and intensity
    final count = (size.width * size.height * intensity * 0.15).toInt();
    final alpha = (intensity * 180).toInt();

    for (var i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      // Alternate between white and black dots for a realistic grain look
      final bright = rng.nextDouble() > 0.5;
      paint.color = bright
          ? Color.fromARGB(alpha, 255, 255, 255)
          : Color.fromARGB(alpha, 0, 0, 0);
      canvas.drawCircle(Offset(x, y), 0.6, paint);
    }
  }

  @override
  bool shouldRepaint(NoisePainter old) =>
      old.intensity != intensity || old.seed != seed;
}
