import 'package:flutter/material.dart';

/// Which ruling is printed on the notebook paper.
enum PaperStyle {
  grid('GRID'),
  dotted('DOTTED'),
  ruled('RULED'),
  blank('BLANK');

  final String label;
  const PaperStyle(this.label);

  static PaperStyle fromName(String? name) =>
      PaperStyle.values.firstWhere((s) => s.name == name, orElse: () => PaperStyle.grid);
}

/// Paints the paper gradient (paper1 -> paper2, top to bottom) plus the
/// 20x20 ruling on top: full grid, dots on the grid vertices, horizontal
/// rules only, or nothing. Sized to the full scroll content so the ruling
/// scrolls with the page rather than sitting as a fixed backdrop.
class PaperPainter extends CustomPainter {
  final Color paper1;
  final Color paper2;
  final Color gridColor;
  final PaperStyle style;
  static const double cell = 20;

  PaperPainter({
    required this.paper1,
    required this.paper2,
    required this.gridColor,
    this.style = PaperStyle.grid,
  });

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

    switch (style) {
      case PaperStyle.grid:
        for (double x = 0; x <= size.width; x += cell) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
        }
        for (double y = 0; y <= size.height; y += cell) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
        }
      case PaperStyle.dotted:
        for (double x = 0; x <= size.width; x += cell) {
          for (double y = 0; y <= size.height; y += cell) {
            canvas.drawCircle(Offset(x, y), 1.1, gridPaint);
          }
        }
      case PaperStyle.ruled:
        for (double y = 0; y <= size.height; y += cell) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
        }
      case PaperStyle.blank:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant PaperPainter oldDelegate) {
    return oldDelegate.paper1 != paper1 ||
        oldDelegate.paper2 != paper2 ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.style != style;
  }
}
