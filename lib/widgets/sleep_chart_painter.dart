import 'package:flutter/material.dart';

import '../models/month_data.dart';

/// Draws the polyline + dots for the sleep chart. `nights` must already be
/// sorted by day. `xFor` maps hours -> x pixel inside the plot band.
class SleepChartPainter extends CustomPainter {
  final List<SleepNight> nights;
  final double Function(double hours) xFor;
  final Color ink;

  SleepChartPainter({required this.nights, required this.xFor, required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    if (nights.isEmpty) return;
    final linePaint = Paint()
      ..color = ink
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final dotPaint = Paint()..color = ink;

    final points = nights.map((n) => Offset(xFor(n.hours), (n.day - 1) * 20 + 10)).toList();

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, linePaint);

    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SleepChartPainter oldDelegate) {
    return oldDelegate.nights != nights || oldDelegate.ink != ink;
  }
}
