import 'package:flutter/material.dart';

/// Highlighter-marker palette for tagging habits. Picked to sit next to the
/// app's own lime highlight (`PaperTokens.hi`, first in the list) rather than
/// clash with it — same saturated, slightly neon character, so ink text
/// always reads fine drawn on top.
const List<Color> habitColorPalette = [
  Color(0xFFB6FF2E), // lime — the app's own highlight
  Color(0xFFFFE156), // yellow
  Color(0xFFFF9F45), // orange
  Color(0xFFFF6B9D), // pink
  Color(0xFF5CD6FF), // sky
  Color(0xFF8C7BFF), // violet
  Color(0xFF4DDFC0), // teal
  Color(0xFFFF6B6B), // coral
];
