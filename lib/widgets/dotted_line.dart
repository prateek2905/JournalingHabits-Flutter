import 'package:flutter/material.dart';

/// A horizontal dotted leader line (profile stat rows).
class DottedLine extends StatelessWidget {
  final Color color;
  final double height;

  const DottedLine({super.key, required this.color, this.height = 14});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          height: 1,
          child: CustomPaint(
            size: const Size(double.infinity, 1),
            painter: _DottedPainter(color),
          ),
        ),
      ),
    );
  }
}

class _DottedPainter extends CustomPainter {
  final Color color;
  _DottedPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dashWidth = 2.0;
    const gap = 2.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedPainter oldDelegate) => oldDelegate.color != color;
}
