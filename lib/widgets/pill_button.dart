import 'package:flutter/material.dart';

import '../theme/paper_tokens.dart';
import '../theme/text_styles.dart';

/// A bordered, irregular-radius "pill" — used for ADD / + HABIT buttons and
/// the stat/callout chips. Matches the hand-drawn asymmetric-radius language
/// from the design tokens.
class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final BorderRadius radius;
  final Color? background;
  final double height;
  final EdgeInsets padding;
  final double borderWidth;
  final double rotationDeg;

  const PillButton({
    super.key,
    required this.label,
    this.onTap,
    this.radius = const BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(9),
      bottomRight: Radius.circular(11),
      bottomLeft: Radius.circular(10),
    ),
    this.background,
    this.height = 20,
    this.padding = const EdgeInsets.symmetric(horizontal: 9),
    this.borderWidth = 1.5,
    this.rotationDeg = 0,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    Widget child = Container(
      height: height,
      padding: padding,
      alignment: Alignment.center,
      decoration: BoxDecoration(borderRadius: radius, color: background),
      // Border via foregroundDecoration so its stroke width doesn't count as
      // implicit padding and shrink the fixed-height box (see CalloutCard).
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: t.ink, width: borderWidth),
        borderRadius: radius,
      ),
      child: Text(label.toUpperCase(), style: PaperText.button(t.ink)),
    );
    if (rotationDeg != 0) {
      child = Transform.rotate(angle: rotationDeg * 3.14159265 / 180, child: child);
    }
    if (onTap == null) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}
