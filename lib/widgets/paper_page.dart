import 'package:flutter/material.dart';

import '../theme/paper_painter.dart';
import '../theme/paper_tokens.dart';

/// Scrollable page body: paper gradient + 20px grid painted behind the
/// content, scrolling together (never a fixed backdrop). Page padding is
/// 40px top, 20px left/right/bottom per the grid spec.
class PaperPage extends StatelessWidget {
  final Widget child;

  const PaperPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    return SingleChildScrollView(
      child: CustomPaint(
        painter: PaperPainter(paper1: t.paper1, paper2: t.paper2, gridColor: t.grid),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
          child: child,
        ),
      ),
    );
  }
}
