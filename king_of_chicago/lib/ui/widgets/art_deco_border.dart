import 'package:flutter/material.dart';

import '../theme/game_theme.dart';

/// A custom painter that draws art deco stepped geometric corners in gold.
///
/// The corners feature classic art deco layered L-shapes that can be used
/// as decoration on any container.
class ArtDecoBorderPainter extends CustomPainter {
  final Color color;
  final double cornerSize;
  final double strokeWidth;

  const ArtDecoBorderPainter({
    this.color = GameTheme.goldAccent,
    this.cornerSize = 16.0,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final s = cornerSize;
    final step = s * 0.45;

    // Top-left corner — stepped L
    _drawCorner(canvas, paint, 0, 0, s, step, topLeft: true);

    // Top-right corner
    _drawCorner(canvas, paint, size.width, 0, s, step, topRight: true);

    // Bottom-left corner
    _drawCorner(canvas, paint, 0, size.height, s, step, bottomLeft: true);

    // Bottom-right corner
    _drawCorner(
      canvas,
      paint,
      size.width,
      size.height,
      s,
      step,
      bottomRight: true,
    );
  }

  void _drawCorner(
    Canvas canvas,
    Paint paint,
    double x,
    double y,
    double s,
    double step, {
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    final dx = (topLeft || bottomLeft) ? 1.0 : -1.0;
    final dy = (topLeft || topRight) ? 1.0 : -1.0;

    // Outer L
    canvas.drawLine(
      Offset(x, y + dy * s),
      Offset(x, y),
      paint,
    );
    canvas.drawLine(
      Offset(x, y),
      Offset(x + dx * s, y),
      paint,
    );

    // Inner stepped L
    canvas.drawLine(
      Offset(x + dx * step, y + dy * s * 0.7),
      Offset(x + dx * step, y + dy * step),
      paint,
    );
    canvas.drawLine(
      Offset(x + dx * step, y + dy * step),
      Offset(x + dx * s * 0.7, y + dy * step),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant ArtDecoBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      cornerSize != oldDelegate.cornerSize ||
      strokeWidth != oldDelegate.strokeWidth;
}

/// Convenience widget that wraps a child with art deco corner decorations.
class ArtDecoBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double cornerSize;
  final double strokeWidth;

  const ArtDecoBorder({
    super.key,
    required this.child,
    this.color = GameTheme.goldAccent,
    this.cornerSize = 16.0,
    this.strokeWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: ArtDecoBorderPainter(
        color: color,
        cornerSize: cornerSize,
        strokeWidth: strokeWidth,
      ),
      child: child,
    );
  }
}
