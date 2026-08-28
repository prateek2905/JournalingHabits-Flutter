import 'package:flutter/material.dart';

/// Paints the paper gradient (paper1 -> paper2, top to bottom) plus the
/// 20x20 grid on top. Sized to the full scroll content so the grid scrolls
/// with the page rather than sitting as a fixed backdrop.
class PaperPainter extends CustomPainter {
  final Color paper1;
  final Color paper2;
  final Color gridColor;
  static const double cell = 20;

  PaperPainter({required this.paper1, required this.paper2, required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [paper1, paper2],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, gradientPaint);

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PaperPainter oldDelegate) {
    return oldDelegate.paper1 != paper1 || oldDelegate.paper2 != paper2 || oldDelegate.gridColor != gridColor;
  }
}
