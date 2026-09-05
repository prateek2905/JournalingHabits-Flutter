import 'package:flutter/material.dart';

import '../theme/paper_tokens.dart';
import '../theme/text_styles.dart';

/// A month-by-month line + dot chart, drawn the same way as the Sleep tab's
/// per-night chart (ink polyline, filled dots) — just laid out horizontally
/// by month instead of vertically by day. A month with no logged data leaves
/// a gap rather than dragging the line down to zero.
class TrendLineChart extends StatelessWidget {
  final List<String> labels; // oldest first
  final List<double?> values;
  final double loValue;
  final double hiValue;
  final double height;
  final String Function(double) formatValue;

  const TrendLineChart({
    super.key,
    required this.labels,
    required this.values,
    required this.loValue,
    required this.hiValue,
    required this.formatValue,
    this.height = 90,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final n = labels.length;
        final step = n <= 1 ? width : width / (n - 1);
        double yFor(double v) {
          final clamped = v.clamp(loValue, hiValue);
          return height - (clamped - loValue) / (hiValue - loValue) * (height - 8) - 4;
        }

        final points = <int, Offset>{};
        for (var i = 0; i < n; i++) {
          final v = values[i];
          if (v != null) points[i] = Offset(i * step, yFor(v));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: height,
              width: width,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(size: Size(width, height), painter: _TrendPainter(points: points, ink: t.ink, hi: t.hi)),
                  for (final entry in points.entries)
                    Positioned(
                      left: entry.value.dx - 16,
                      top: (entry.value.dy - 16).clamp(-14, height - 14).toDouble(),
                      width: 32,
                      child: Text(
                        formatValue(values[entry.key]!),
                        textAlign: TextAlign.center,
                        style: PaperText.small(t.ink, size: 9).copyWith(color: t.ink.withValues(alpha: t.ink.a * .65)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < n; i++)
                    Text(labels[i], style: PaperText.small(t.ink, size: 10).copyWith(color: t.ink.withValues(alpha: t.ink.a * .6))),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TrendPainter extends CustomPainter {
  final Map<int, Offset> points;
  final Color ink;
  final Color hi;

  _TrendPainter({required this.points, required this.ink, required this.hi});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final linePaint = Paint()
      ..color = ink
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final sortedKeys = points.keys.toList()..sort();
    for (var i = 0; i < sortedKeys.length - 1; i++) {
      final a = sortedKeys[i], b = sortedKeys[i + 1];
      if (b == a + 1) {
        canvas.drawLine(points[a]!, points[b]!, linePaint);
      }
    }
    for (final p in points.values) {
      canvas.drawCircle(p, 3.5, Paint()..color = ink);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.ink != ink || oldDelegate.hi != hi;
}
