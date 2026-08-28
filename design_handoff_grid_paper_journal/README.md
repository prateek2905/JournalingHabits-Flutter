# Handoff: Grid Paper — Habit Tracking & Journaling App (Flutter)

## Overview
A mobile bullet-journal app that replicates a physical grid-paper notebook. Four tabs: **Journal** (daily tasks + memorable moments), **Habits** (month grid of X marks), **Sleep** (month line graph, plotted vertically), **Profile** (stats, settings, dark mode).

The defining characteristic: **everything sits on a single 20 px paper grid**. The grid is drawn once, scrolls with the content, and every row height, column width, header height and vertical offset is a multiple of 20 px so ink always lands inside a paper square. This is the thing to get right; if a row is 22 px tall the whole design falls apart.

## About the Design Files
`Bullet Journal App.dc.html` in this bundle is a **design reference prototype written in HTML/JS** — it shows intended look and behavior. It is not production code to port line by line. The task is to **recreate it as a Flutter app** using idiomatic Flutter (widgets, `ThemeExtension` or an InheritedWidget for tokens, a state solution of your choice — `ChangeNotifier`/Riverpod/Bloc all fine) with real persistence.

Open the HTML file in a browser to interact with it (tab switching, month/day nav, toggling X's, crossing off tasks, hold-to-delete, dark mode).

## Fidelity
**High fidelity.** Colors, type sizes, spacing and grid geometry are final. Recreate them precisely. Fonts are Google Fonts: **Caveat** (700, headings) and **Kalam** (400, everything else) — both available via the `google_fonts` package.

---

## Design tokens

### Light theme
| Token | Value | Used for |
|---|---|---|
| paper1 | #FAF4E3 | paper gradient top |
| paper2 | #F2EAD4 | paper gradient bottom |
| barA | rgba(250,244,227,.5) | tab bar gradient top |
| barB | rgba(242,234,212,.95) | tab bar gradient bottom |
| ink | #23241F | all text, all ruled lines |
| ink65 | rgba(35,36,31,.65) | heavy rules (table top/bottom) |
| ink60 | rgba(35,36,31,.6) | secondary text |
| ink50 | rgba(35,36,31,.5) | input underline, column rules |
| ink40 | rgba(35,36,31,.4) | section divider, placeholder glyphs |
| ink30 | rgba(35,36,31,.3) | dotted leader lines |
| grid | rgba(96,98,72,.2) | the 20 px paper grid |
| hi | #B6FF2E | neon highlighter (active tab, buttons) |
| hiFill | rgba(182,255,46,.4) | filled callout cards |
| hiSoft | rgba(182,255,46,.26) | row hover / press |
| onHi | #23241F | text/icon ON a solid neon fill |
| room1/2/3 | #ADBBA6 / #90A08C / #7F8F7C | backdrop behind the phone (web only) |

### Dark theme
| Token | Value |
|---|---|
| paper1 | #24261F |
| paper2 | #191B16 |
| barA | rgba(36,38,31,.6) |
| barB | rgba(25,27,22,.95) |
| ink | #F0EAD6 |
| ink65 | rgba(240,234,214,.62) |
| ink60 | rgba(240,234,214,.55) |
| ink50 | rgba(240,234,214,.45) |
| ink40 | rgba(240,234,214,.35) |
| ink30 | rgba(240,234,214,.25) |
| grid | rgba(214,226,178,.16) |
| hi | #B6FF2E |
| hiFill | rgba(182,255,46,.28) |
| hiSoft | rgba(182,255,46,.16) |
| onHi | #1B1D17 |
| room1/2/3 | #3C463A / #2B322A / #222820 |

Neon (#B6FF2E) is the ONLY accent, in both themes. Never put light text on it — use `onHi`.

### Type scale (all uppercase except inputs' placeholder casing)
| Role | Font | Size | Line height | Notes |
|---|---|---|---|---|
| Month / date title | Caveat 700 | 34 | 40 | letter-spacing .5, `nowrap`, 2 px ink underline directly beneath |
| Header sub-note | Kalam 400 | 12 | 20 | opacity .6, uppercase, letter-spacing .4 |
| Section heading | Kalam 400 | 17 | 20 | letter-spacing 1.2, 2 px ink bottom border, `nowrap` |
| Section meta | Kalam 400 | 12 | 20 | opacity .55, `nowrap` |
| Body row / list item | Kalam 400 | 14 | 20 | letter-spacing .2 |
| Small numerals (day, score) | Kalam 400 | 10–11 | 20 | opacity .6–.75 |
| Grid X mark | Kalam 400 | 16 | 1 | glyphs cycle ✕ / × / ✗ |
| Tab label | Kalam 400 | 14 | — | letter-spacing .6; active is 700 in `onHi` |
| Button ("ADD", "+ HABIT") | Kalam 400 | 13 | 18 | 20 px tall pill, 1.5 px ink border |

### The grid (non-negotiable)
- Cell size **20 × 20 px**, 1 px lines in `grid` colour, origin at the top-left of the scrolling content.
- Page padding: **40 px top** (2 rows, keeps content clear of the status bar), **20 px** left/right/bottom.
- Every block height is a multiple of 20: month header 80, section header 40, list row 20, input row 40, habit column-label header 120, sleep tick row 20.
- Horizontal offsets are multiples of 20 too: habit day column 20, weight column 40, each habit column 20; sleep day column 20, chart 280, score column 40.
- Rules drawn ON the grid (table top rule, total-row rule, chart side rules) must NOT consume layout height. In HTML they are `inset box-shadow`; in Flutter draw them with a `CustomPainter` or `Container` overlays / `Stack`, never as a `Border` that adds to the box.
- Paper background: a vertical gradient paper1→paper2, plus the grid painted on top; both scroll with the content (grid must not be a fixed backdrop).

### Shapes
Hand-drawn feel comes from **asymmetric border radii** on every bordered element, e.g. `12px 9px 11px 10px`, plus 1.5–2 px ink borders and a ±0.5°–1.6° rotation on callout cards. Radii vary per element on purpose; keep them irregular.

---

## Screens

### 1. Journal (default tab) — day view
**Purpose:** read/write one day at a time.

Layout, top to bottom:
1. **Header (80 px)** — left: date title `FRI 28 AUG` (weekday + day + 3-letter month, Caveat 34/40) with 2 px underline, then sub-note `AUGUST 2026 · TODAY` (12/20, opacity .6). Right: nav buttons (see below). The header row is bottom-aligned.
2. **TASKS section header (40 px)** — "TASKS" + meta `N OPEN · TAP TO CROSS OFF`.
3. **Task rows (20 px each)** — 20 px glyph column (□ open / ✕ done, 15 px) + text. Done rows: line-through 2 px, opacity .42. Tap toggles. Press/hover tint `hiSoft`.
4. Empty state (20 px): `NOTHING ON THE LIST FOR THIS DAY`, opacity .4, left-padded 28 px.
5. **Add-task row (20 px, 20 px top margin)** — □ glyph, underlined text field (2 px `ink50` underline), "ADD" pill. Enter or ADD commits, uppercases the text.
6. **MEMORABLE MOMENTS header (40 px + 20 px top padding)** — heading + meta `N IN AUG` (count for the whole month).
7. **Moment rows (20 px each)** — "·" bullet column + text. **Press-and-hold 550 ms deletes** the moment (no tap action, no cross-off — crossing off belongs to tasks only). Hover/press tint `hiSoft`.
8. Empty state: `NO MOMENT WRITTEN YET`.
9. **Add-moment row (40 px)** — "+" glyph, underlined field, "ADD" pill.
10. **Intentions block** — 2 px `ink40` top rule, label `AUGUST 2026 INTENTIONS` (13/20, opacity .6), then one 14/20 line of copy.

**Nav buttons move by DAY here.** Back at day 1 jumps to the last day of the previous month; forward is disabled (opacity .3) at the current day (28 Aug 2026).

### 2. Habits — month grid
**Purpose:** X off habits for every day of the month. Modelled on the reference photo: days run DOWN, habits run ACROSS as rotated labels.

1. Header (80 px) — month title `AUGUST 2026`, sub-note `DAY 28 · IN PROGRESS` (current month) or `ARCHIVED · N X'S` (past months).
2. Section header (40 px) — "HABIT TRACKER" + meta `TAP TO X`.
3. Horizontally scrollable table:
   - **Column-label header, 120 px tall**: 20 px spacer, then "WEIGHT KG" (40 px wide), then one 20 px column per habit. Labels are **rotated to read bottom-to-top** (CSS `writing-mode: vertical-rl` + 180° — in Flutter `RotatedBox(quarterTurns: 3)`), 11 px, bottom-aligned.
   - **Day rows, 20 px each**: day number (20 px, right-aligned, 11 px, opacity .65); weight cell (40 px, 11 px, 2 px `ink50` rules left and right, value every 3rd day else "—"); then one 20 px cell per habit. Tapping a cell toggles the mark; marks cycle ✕ / × / ✗ by (habit + day) % 3 so the page looks hand-written. Mark animates in: 180 ms ease-out, scale .4→1, rotate −14°→0, opacity 0→1.
   - 2 px heavy rule above the first day row and above the total row.
   - **TOTAL row (20 px)**: per-habit count of marks for the month.
4. **Add-habit row (40 px)** — underlined field + "+ HABIT" pill; new habits append as a new column and apply to all months.
5. **Stat chips (20 px tall, 20 px top padding)**, wrapping row: `N X'S THIS MONTH` (neon `hiFill`), `BEST STREAK N DAYS`, `TODAY N/M DONE` — 1.5 px ink borders, irregular radii, tiny rotations.

Default habits (10): COLD EXPOSURE, EXERCISE, STRETCHING, NO PHONE AM, MEDITATION, READ 5 PAGES, FLOSS TEETH, JOURNAL, COFFEE, SAUNA.

**Nav buttons move by MONTH.**

### 3. Sleep — month graph
**Purpose:** see the month's sleep at a glance. The graph is **vertical**: days run down, hours run across (as in the reference photo).

1. Header (80 px) — month title + sub-note.
2. Section header (40 px) — "SLEEP" + meta `AVG N.Nh`.
3. Hour-tick row (20 px): 20 px spacer, 280 px band with tick labels 4…10 positioned with the **same mapping as the plot** (`x(v) = (v − 4) / 6 × 92 % + 4 %` of the 280 px band, centered via −50 % translate), then a 40 px right column labelled "SCORE".
4. Chart body — three columns:
   - 20 px day numbers, one per 20 px row.
   - 280 px plot area with 2 px ink rules on both sides (drawn without consuming width). Polyline through one point per night: `x = x(hours)`, `y = rowIndex × 20 + 10`. 1.6 px ink stroke, round joins. An 8 px ink dot at every point, centered on its row. Each 20 px row is tappable (tint `hiSoft` on press) and selects that night.
   - 40 px sleep-score column, right-aligned, 11 px, opacity .75.
5. **Selected-night card (40 px, 20 px top margin)** — 1.5 px ink border, irregular radius, `hiFill` background, −0.6° rotation. Line 1: `AUG 28 · 7.4H · SCORE 79` (14/20). Line 2 (12/18, opacity .75) is one of: ≥8h "SOLID NIGHT. WOKE UP EASY." / ≥7h "DECENT. COULD GO TO BED EARLIER." / else "SHORT ONE — LATE EDIT SESSION."

Hours range 4–10 (clamped); scores clamped to 41–99.

**Nav buttons move by MONTH.**

### 4. Profile
1. Header (80 px) — month title + sub-note (this tab has its own month too).
2. Section header (40 px) — "ME" + meta `SINCE JUNE 2025`.
3. Identity row (80 px): 60 px circle avatar, 2 px ink border, `hiFill`-ish neon tint, simple ink head+shoulders silhouette; name in Caveat 28/40; `14 NOTEBOOKS · 428 ENTRIES` at 13/20 opacity .65.
4. Stat rows (20 px each) — label left, dotted `ink30` leader, value right: BEST STREAK <MON>, X'S IN <MON>, MOMENTS IN <MON>, AVG SLEEP <MON>, MONTHS KEPT.
5. SETTINGS label (20 px, 13/20, opacity .6), then:
   - **Dark mode row (20 px)** — 32 × 14 px pill switch, 1.5 px ink border, 9 px knob (ink when off at left, neon at right when on), label `DARK MODE · ON/OFF`.
   - Three checkbox rows (20 px): ✕ when on, blank when off — NIGHTLY REMINDER 9:30PM (on), WEEK STARTS MONDAY (on), SYNC SLEEP FROM RING (on), SHOW WEIGHT COLUMN (off).
6. Export card (40 px) — neon `hiFill`, +0.5° rotation: `EXPORT AUGUST AS PDF` / `PRINTS ON GRID PAPER, 1:1`.

### Tab bar (all screens)
Fixed at the bottom, outside the scroll area: 2 px `ink50` top rule, barA→barB gradient, 6 px top / 12 px side padding, 30 px bottom inset (home indicator). Three equal-width text tabs — JOURNAL, HABITS, SLEEP — plus a **44 px icon-only Profile** tab at the right (24 px circle with ink head + shoulders). The active tab gets a **neon marker bar** behind the label (absolutely positioned, 17 px tall, inset 8 px, irregular radius, ±1° rotation) and its label switches to `onHi` at weight 700; the active profile icon switches its strokes to `onHi`.

### Header nav buttons (all screens)
Two buttons, 28 × 40 px each, 4 px gap (60 × 40 total = 3 cols × 2 rows). 2 px ink border, mirrored irregular radii (`14px 4px 13px 5px` / `5px 13px 4px 14px`), "<" and ">" in Caveat 22. Press tint neon. Disabled = opacity .3.

---

## Interactions & behavior
- **Tab switch** — instant, no transition.
- **Per-tab navigation state, independent by design.** Journal keeps its own (month, day); Habits, Sleep and Profile each keep their own month. Changing the month on Habits must NOT move the Journal or Sleep.
- **Journal arrows step one day** and roll over month boundaries; forward is capped at "today". **Habits/Sleep/Profile arrows step one month**, capped at the newest month.
- **Habit cell tap** toggles a mark (with the 180 ms ink-in animation).
- **Task tap** toggles done (glyph + line-through).
- **Moment press-and-hold 550 ms** deletes it; releasing early cancels. Consider a light haptic on delete.
- **Add task / add moment / add habit** — commit on the pill button or keyboard submit; input is uppercased; blank input is ignored. New task/moment attaches to the currently viewed day; new habit applies to every month.
- **Sleep row tap** selects that night and updates the card.
- **Dark mode toggle** swaps the whole token set (paper, ink, grid, highlight, chrome, status bar) instantly.
- Hover/press feedback everywhere is a `hiSoft` row tint.
- Month range in the prototype: **June 2025 → August 2026**, "today" = 28 August 2026. Real app: unlimited past months, current month partial up to today.

## State
| State | Shape | Notes |
|---|---|---|
| `tab` | enum {journal, habits, sleep, profile} | |
| `journalMonth`, `journalDay` | int, int | day-level cursor |
| `habitsMonth`, `sleepMonth`, `profileMonth` | int | independent month cursors |
| `selectedNight` | int (day) | sleep card |
| `habits` | List&lt;String&gt; | global, applies to all months |
| `monthData[month]` | `{ marks: Set<"habitIndex:day">, nights: List<{day, hours, score}>, entries: List<{day, text}>, tasks: List<{day, text, done}>, weights: Map<day, double> }` | |
| `dark` | bool | persist |
| `settingsFlags` | List&lt;bool&gt; | persist |
| drafts | String ×3 | task / moment / habit input text |

Persistence: the prototype is in-memory with seeded demo data. For the real app persist locally (Hive / Isar / sqflite / shared_preferences for flags) so months and marks survive restarts; sleep data could later sync from a wearable (the "SYNC SLEEP FROM RING" setting hints at it).

## Flutter implementation notes
- Draw the paper (gradient + 20 px grid) with a single `CustomPainter` behind a `SingleChildScrollView`, sized to the content so it scrolls with it.
- Snap every row to 20 px: `SizedBox(height: 20)` rows, `height: 40` headers. Use `Text` with explicit `height: 20 / fontSize` so line boxes are exactly 20 px — do not rely on default line heights.
- The habit table: outer `SingleChildScrollView(scrollDirection: Axis.horizontal)` wrapping a `Column` of `Row`s of 20 px `SizedBox`es; rotated labels via `RotatedBox(quarterTurns: 3)`.
- The sleep graph: `Stack` — `CustomPainter` for polyline + dots, `Column` of 20 px `GestureDetector` rows on top for hit testing.
- Theme: two `ThemeExtension`s (light/dark token sets) so widgets read `Theme.of(context).extension<PaperTokens>()`.
- Hold-to-delete: `GestureDetector(onLongPress:)` with `longPressDuration` ≈ 550 ms, or a `Timer` on `onTapDown`/`onTapUp`.
- Fonts: `google_fonts` — `GoogleFonts.caveat`, `GoogleFonts.kalam`.
- Minimum tap targets: the 20 px grid rows are visually correct but small; give `GestureDetector`s generous hit slop (`behavior: HitTestBehavior.opaque`, and consider `MaterialTapTargetSize` padding) so real fingers can hit habit cells and task rows.

## Assets
None — no images, no icon fonts. Every glyph is a text character (✕ × ✗ □ · + < >) and the avatar/profile icon is built from a circle plus a rounded rectangle. The device bezel in the HTML preview is prototype chrome only; do not build it.

## Screenshots
`screenshots/` holds one capture per tab in each theme, taken from the reference prototype:
01 journal-light, 02 habits-light, 03 sleep-light, 04 profile-light, 05 profile-dark, 06 journal-dark, 07 habits-dark, 08 sleep-dark. The iPhone bezel and the green backdrop in these images are prototype chrome, not part of the app.

## Files
- `Bullet Journal App.dc.html` — the full interactive design reference (all four tabs, both themes).
- `ios-frame.jsx` — the iPhone bezel used by the prototype preview. **Prototype scaffolding only**, not part of the app.
