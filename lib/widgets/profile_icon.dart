import 'package:flutter/material.dart';

/// The ink head-and-shoulders silhouette used for the avatar and the
/// bottom-tab profile icon. Pure shapes — there are no image assets in this
/// design (see handoff README "Assets" section).
class ProfileIcon extends StatelessWidget {
  final double size;
  final Color glyphColor;
  final Color? borderColor;
  final double borderWidth;
  final Color? background;

  const ProfileIcon({
    super.key,
    required this.size,
    required this.glyphColor,
    this.borderColor,
    this.borderWidth = 1.8,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
        border: borderColor == null ? null : Border.all(color: borderColor!, width: borderWidth),
      ),
      child: CustomPaint(
        painter: _SilhouettePainter(glyphColor),
        size: Size(size, size),
      ),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  final Color color;
  _SilhouettePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final headR = size.width * .3;
    canvas.drawCircle(Offset(size.width / 2, size.height * .35), headR, paint);
    final shoulderW = size.width * .64;
    final shoulderH = size.height * .5;
    final rect = Rect.fromLTWH(
      (size.width - shoulderW) / 2,
      size.height - shoulderH,
      shoulderW,
      shoulderH,
    );
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(shoulderW / 2),
      topRight: Radius.circular(shoulderW / 2),
    );
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _SilhouettePainter oldDelegate) => oldDelegate.color != color;
}
