import 'dart:math';
import 'package:flutter/material.dart';

/// A subtle film grain/noise overlay that creates vintage film texture.
///
/// Uses a custom painter with random dots at low opacity. Sits on top
/// of content to add that old-film feeling.
class GrainOverlay extends StatelessWidget {
  final double opacity;

  const GrainOverlay({super.key, this.opacity = 0.04});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _GrainPainter(opacity: opacity),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  final double opacity;

  const _GrainPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); // Fixed seed for consistent grain
    final paint = Paint()..style = PaintingStyle.fill;

    final dotCount = (size.width * size.height / 60).toInt().clamp(0, 8000);

    for (int i = 0; i < dotCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final brightness = random.nextInt(200);

      paint.color = Color.fromARGB(
        (opacity * 255).toInt(),
        brightness,
        brightness,
        brightness,
      );

      canvas.drawCircle(Offset(x, y), 0.5 + random.nextDouble() * 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) =>
      opacity != oldDelegate.opacity;
}
