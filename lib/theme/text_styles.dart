import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Text style helpers. Every style pins an explicit `height` so line boxes
/// land on the 20px grid instead of relying on font metrics.
class PaperText {
  /// Month / date title — Caveat 700, 34/40.
  static TextStyle title(Color color) => GoogleFonts.caveat(
        fontSize: 34,
        height: 40 / 34,
        letterSpacing: .5,
        fontWeight: FontWeight.w700,
        color: color,
      );

  /// Header sub-note — Kalam 400, 12/20, opacity .6.
  static TextStyle subNote(Color color) => GoogleFonts.kalam(
        fontSize: 12,
        height: 20 / 12,
        letterSpacing: .4,
        color: color.withValues(alpha: color.a * .6),
      );

  /// Section heading — Kalam 400, 17/20.
  static TextStyle sectionHeading(Color color) => GoogleFonts.kalam(
        fontSize: 17,
        height: 20 / 17,
        letterSpacing: 1.2,
        color: color,
      );

  /// Section meta — Kalam 400, 12/20, opacity .55.
  static TextStyle sectionMeta(Color color) => GoogleFonts.kalam(
        fontSize: 12,
        height: 20 / 12,
        color: color.withValues(alpha: color.a * .55),
      );

  /// Body row / list item — Kalam 400, 14/20.
  static TextStyle body(Color color) => GoogleFonts.kalam(
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: .2,
        color: color,
      );

  /// Small numerals (day, score) — Kalam 400, 10-11/20.
  static TextStyle small(Color color, {double size = 11}) => GoogleFonts.kalam(
        fontSize: size,
        height: 20 / size,
        color: color,
      );

  /// Grid X mark — Kalam 400, 16, line height 1.
  static TextStyle gridMark(Color color) => GoogleFonts.kalam(
        fontSize: 16,
        height: 1,
        color: color,
      );

  /// Tab label — Kalam 400, 14.
  static TextStyle tabLabel(Color color, {bool active = false}) => GoogleFonts.kalam(
        fontSize: 14,
        letterSpacing: .6,
        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
        color: color,
      );

  /// Button — Kalam 400, 13/18.
  static TextStyle button(Color color) => GoogleFonts.kalam(
        fontSize: 13,
        height: 18 / 13,
        color: color,
      );

  /// Caveat nav arrows.
  static TextStyle navArrow(Color color) => GoogleFonts.caveat(
        fontSize: 22,
        height: 1,
        color: color,
      );

  /// Caveat name, 28/40.
  static TextStyle name(Color color) => GoogleFonts.caveat(
        fontSize: 28,
        height: 40 / 28,
        fontWeight: FontWeight.w700,
        color: color,
      );
}
