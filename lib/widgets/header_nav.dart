import 'package:flutter/material.dart';

import '../theme/paper_tokens.dart';
import '../theme/text_styles.dart';

/// The 80px header used on every screen: title + underline + sub-note on
/// the left, two nav buttons (28x40, 4px gap) on the right, bottom-aligned.
class HeaderNav extends StatelessWidget {
  final String title;
  final String subNote;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final bool nextEnabled;

  const HeaderNav({
    super.key,
    required this.title,
    required this.subNote,
    required this.onPrev,
    required this.onNext,
    this.nextEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.rotate(
                  angle: -.5 * 3.14159265 / 180,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title.toUpperCase(), style: PaperText.title(t.ink), maxLines: 1, overflow: TextOverflow.visible),
                      Container(height: 2, color: t.ink, margin: const EdgeInsets.only(top: 2)),
                    ],
                  ),
                ),
                Text(subNote.toUpperCase(), style: PaperText.subNote(t.ink)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 60,
            height: 40,
            child: Row(
              children: [
                _NavButton(
                  label: '<',
                  onTap: onPrev,
                  radius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(13),
                    bottomLeft: Radius.circular(5),
                  ),
                ),
                const SizedBox(width: 4),
                _NavButton(
                  label: '>',
                  onTap: nextEnabled ? onNext : null,
                  disabled: !nextEnabled,
                  radius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(13),
                    bottomRight: Radius.circular(4),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final BorderRadius radius;
  final bool disabled;

  const _NavButton({required this.label, required this.onTap, required this.radius, this.disabled = false});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    return Opacity(
      opacity: widget.disabled ? .3 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
        onTapUp: widget.onTap == null ? null : (_) => setState(() => _pressed = false),
        onTapCancel: widget.onTap == null ? null : () => setState(() => _pressed = false),
        child: Container(
          width: 28,
          height: 40,
          alignment: Alignment.center,
          padding: const EdgeInsets.only(bottom: 3),
          decoration: BoxDecoration(borderRadius: widget.radius, color: _pressed ? t.hi : null),
          // Border via foregroundDecoration so its stroke width doesn't count as
          // implicit padding and shrink the fixed-size box (see CalloutCard).
          foregroundDecoration: BoxDecoration(
            border: Border.all(color: t.ink, width: 2),
            borderRadius: widget.radius,
          ),
          child: Text(widget.label, style: PaperText.navArrow(_pressed ? t.onHi : t.ink)),
        ),
      ),
    );
  }
}
