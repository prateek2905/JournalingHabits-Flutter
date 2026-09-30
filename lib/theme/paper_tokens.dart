import 'package:flutter/material.dart';

/// Design tokens for the grid-paper journal, ported 1:1 from the design
/// handoff (`design_handoff_grid_paper_journal/README.md`).
class PaperTokens extends ThemeExtension<PaperTokens> {
  final Color paper1;
  final Color paper2;
  final Color barA;
  final Color barB;
  final Color ink;
  final Color ink65;
  final Color ink60;
  final Color ink50;
  final Color ink40;
  final Color ink30;
  final Color grid;
  final Color hi;
  final Color hiFill;
  final Color hiSoft;
  final Color onHi;

  const PaperTokens({
    required this.paper1,
    required this.paper2,
    required this.barA,
    required this.barB,
    required this.ink,
    required this.ink65,
    required this.ink60,
    required this.ink50,
    required this.ink40,
    required this.ink30,
    required this.grid,
    required this.hi,
    required this.hiFill,
    required this.hiSoft,
    required this.onHi,
  });

  /// Derives a full token set from the colors that define a colorway; ink
  /// tints and highlighter alphas follow the light/dark conventions.
  factory PaperTokens._build({
    required int paper1,
    required int paper2,
    required int ink,
    required int grid,
    bool dark = false,
  }) {
    Color inkAt(int a) => Color((a << 24) | (ink & 0xFFFFFF));
    Color hiAt(int a) => Color((a << 24) | 0xB6FF2E);
    return PaperTokens(
      paper1: Color(paper1),
      paper2: Color(paper2),
      barA: Color((0x80 << 24) | (paper1 & 0xFFFFFF)),
      barB: Color((0xF2 << 24) | (paper2 & 0xFFFFFF)),
      ink: Color(ink),
      ink65: inkAt(dark ? 0x9E : 0xA6),
      ink60: inkAt(dark ? 0x8C : 0x99),
      ink50: inkAt(dark ? 0x73 : 0x80),
      ink40: inkAt(dark ? 0x59 : 0x66),
      ink30: inkAt(dark ? 0x40 : 0x4D),
      grid: Color(grid),
      hi: const Color(0xFFB6FF2E),
      hiFill: hiAt(dark ? 0x47 : 0x66),
      hiSoft: hiAt(dark ? 0x29 : 0x42),
      onHi: Color(dark ? 0xFF1B1D17 : 0xFF23241F),
    );
  }

  static const light = PaperTokens(
    paper1: Color(0xFFFDFCF8),
    paper2: Color(0xFFF1EFE8),
    barA: Color(0x80FDFCF8),
    barB: Color(0xF2F1EFE8),
    ink: Color(0xFF23241F),
    ink65: Color(0xA623241F),
    ink60: Color(0x9923241F),
    ink50: Color(0x8023241F),
    ink40: Color(0x6623241F),
    ink30: Color(0x4D23241F),
    grid: Color(0x33606248),
    hi: Color(0xFFB6FF2E),
    hiFill: Color(0x66B6FF2E),
    hiSoft: Color(0x42B6FF2E),
    onHi: Color(0xFF23241F),
  );

  static const dark = PaperTokens(
    paper1: Color(0xFF24261F),
    paper2: Color(0xFF191B16),
    barA: Color(0x99242611),
    barB: Color(0xF2191B16),
    ink: Color(0xFFF0EAD6),
    ink65: Color(0x9EF0EAD6),
    ink60: Color(0x8CF0EAD6),
    ink50: Color(0x73F0EAD6),
    ink40: Color(0x59F0EAD6),
    ink30: Color(0x40F0EAD6),
    grid: Color(0x29D6E2B2),
    hi: Color(0xFFB6FF2E),
    hiFill: Color(0x47B6FF2E),
    hiSoft: Color(0x29B6FF2E),
    onHi: Color(0xFF1B1D17),
  );

  @override
  PaperTokens copyWith({
    Color? paper1,
    Color? paper2,
    Color? barA,
    Color? barB,
    Color? ink,
    Color? ink65,
    Color? ink60,
    Color? ink50,
    Color? ink40,
    Color? ink30,
    Color? grid,
    Color? hi,
    Color? hiFill,
    Color? hiSoft,
    Color? onHi,
  }) {
    return PaperTokens(
      paper1: paper1 ?? this.paper1,
      paper2: paper2 ?? this.paper2,
      barA: barA ?? this.barA,
      barB: barB ?? this.barB,
      ink: ink ?? this.ink,
      ink65: ink65 ?? this.ink65,
      ink60: ink60 ?? this.ink60,
      ink50: ink50 ?? this.ink50,
      ink40: ink40 ?? this.ink40,
      ink30: ink30 ?? this.ink30,
      grid: grid ?? this.grid,
      hi: hi ?? this.hi,
      hiFill: hiFill ?? this.hiFill,
      hiSoft: hiSoft ?? this.hiSoft,
      onHi: onHi ?? this.onHi,
    );
  }

  @override
  PaperTokens lerp(ThemeExtension<PaperTokens>? other, double t) {
    if (other is! PaperTokens) return this;
    return PaperTokens(
      paper1: Color.lerp(paper1, other.paper1, t)!,
      paper2: Color.lerp(paper2, other.paper2, t)!,
      barA: Color.lerp(barA, other.barA, t)!,
      barB: Color.lerp(barB, other.barB, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      ink65: Color.lerp(ink65, other.ink65, t)!,
      ink60: Color.lerp(ink60, other.ink60, t)!,
      ink50: Color.lerp(ink50, other.ink50, t)!,
      ink40: Color.lerp(ink40, other.ink40, t)!,
      ink30: Color.lerp(ink30, other.ink30, t)!,
      grid: Color.lerp(grid, other.grid, t)!,
      hi: Color.lerp(hi, other.hi, t)!,
      hiFill: Color.lerp(hiFill, other.hiFill, t)!,
      hiSoft: Color.lerp(hiSoft, other.hiSoft, t)!,
      onHi: Color.lerp(onHi, other.onHi, t)!,
    );
  }
}

/// Notebook paper colorways. Each one is a full token set; [isDark] drives
/// the Material brightness and status-bar icon color.
enum PaperTheme {
  light('WHITE', false),
  dark('BLACK', true),
  oldPaper('OLD PAPER', false),
  legalPad('LEGAL PAD', false),
  kraft('KRAFT', false),
  engineering('GREEN', false),
  sky('BLUE', false),
  blueprint('BLUEPRINT', true);

  final String label;
  final bool isDark;
  const PaperTheme(this.label, this.isDark);

  PaperTokens get tokens {
    switch (this) {
      case PaperTheme.light:
        return PaperTokens.light;
      case PaperTheme.dark:
        return PaperTokens.dark;
      case PaperTheme.oldPaper:
        return PaperTokens._build(
            paper1: 0xFFF3E4B8, paper2: 0xFFE6D3A0, ink: 0xFF3A2E1A, grid: 0x408B6B2E);
      case PaperTheme.legalPad:
        return PaperTokens._build(
            paper1: 0xFFFBF3A5, paper2: 0xFFF2E88A, ink: 0xFF1F2A44, grid: 0x554A80C0);
      case PaperTheme.kraft:
        return PaperTokens._build(
            paper1: 0xFFD9BC8C, paper2: 0xFFC8A874, ink: 0xFF2B2118, grid: 0x405A4126);
      case PaperTheme.engineering:
        return PaperTokens._build(
            paper1: 0xFFE4F0D8, paper2: 0xFFD3E5C4, ink: 0xFF1F2B1D, grid: 0x4D3F7A3A);
      case PaperTheme.sky:
        return PaperTokens._build(
            paper1: 0xFFE3EEF8, paper2: 0xFFD0E2F2, ink: 0xFF1B2838, grid: 0x4D4A7FB0);
      case PaperTheme.blueprint:
        return PaperTokens._build(
            paper1: 0xFF1E3A6E,
            paper2: 0xFF152B55,
            ink: 0xFFF2F6FF,
            grid: 0x40BFD8FF,
            dark: true);
    }
  }

  static PaperTheme fromName(String? name, {bool legacyDark = false}) {
    for (final t in values) {
      if (t.name == name) return t;
    }
    return legacyDark ? PaperTheme.dark : PaperTheme.light;
  }
}

extension PaperTokensContext on BuildContext {
  PaperTokens get paper => Theme.of(this).extension<PaperTokens>() ?? PaperTokens.light;
}
