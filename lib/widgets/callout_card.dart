import 'package:flutter/material.dart';

import '../theme/paper_tokens.dart';
import '../theme/text_styles.dart';

/// The 40px neon-fill callout card (sleep selected-night summary, profile
/// export card) — irregular radius, slight rotation, two lines of text.
class CalloutCard extends StatelessWidget {
  final String line1;
  final String line2;
  final BorderRadius radius;
  final double rotationDeg;
  final double topMargin;

  const CalloutCard({
    super.key,
    required this.line1,
    required this.line2,
    this.radius = const BorderRadius.only(
      topLeft: Radius.circular(14), topRight: Radius.circular(11),
      bottomRight: Radius.circular(15), bottomLeft: Radius.circular(12),
    ),
    this.rotationDeg = 0,
    this.topMargin = 20,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    return Padding(
      padding: EdgeInsets.only(top: topMargin),
      child: Transform.rotate(
        angle: rotationDeg * 3.14159265 / 180,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            border: Border.all(color: t.ink, width: 1.5),
            borderRadius: radius,
            color: t.hiFill,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(line1.toUpperCase(), style: PaperText.body(t.ink).copyWith(letterSpacing: .4), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(line2.toUpperCase(), style: _secondaryLine(t.ink)),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _secondaryLine(Color ink) {
    return PaperText.subNote(ink).copyWith(fontSize: 12, height: 18 / 12, letterSpacing: 0, color: ink.withValues(alpha: ink.a * .75));
  }
}
