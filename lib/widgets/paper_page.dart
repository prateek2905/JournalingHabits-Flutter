import 'package:flutter/material.dart';

import '../theme/paper_painter.dart';
import '../theme/paper_tokens.dart';

/// Scrollable page body: paper gradient + 20px grid painted behind the
/// content, scrolling together (never a fixed backdrop). The paper runs
/// edge-to-edge — including behind the status bar/notch — with content
/// padded clear of it, and always fills at least the full screen height so
/// short content doesn't leave a plain, grid-less gap at the bottom.
class PaperPage extends StatelessWidget {
  final Widget child;

  const PaperPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    // 40px covers the classic ~20px status bar; taller notches/Dynamic
    // Islands need more — round up to the next grid row so the title still
    // lands on a 20px line.
    final topInset = MediaQuery.of(context).padding.top;
    final topPad = topInset <= 40 ? 40.0 : (topInset / 20).ceilToDouble() * 20;

    return LayoutBuilder(
      builder: (context, constraints) {
        // IndexedStack lays every tab out with the same constraints it was
        // given; guard against an unbounded one reaching us (e.g. from an
        // ancestor that doesn't itself impose a height) instead of forcing
        // an infinitely tall — and therefore unscrollable — page.
        final minHeight = constraints.hasBoundedHeight ? constraints.maxHeight : MediaQuery.of(context).size.height;
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: CustomPaint(
              painter: PaperPainter(paper1: t.paper1, paper2: t.paper2, gridColor: t.grid),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, topPad, 20, 20),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
