import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/paper_tokens.dart';
import '../theme/text_styles.dart';
import 'profile_icon.dart';

class BottomTabBar extends StatelessWidget {
  final AppTab tab;
  final ValueChanged<AppTab> onSelect;

  const BottomTabBar({super.key, required this.tab, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(12, 6, 12, 12 + bottomInset),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: t.ink50, width: 2)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [t.barA, t.barB],
        ),
      ),
      child: Row(
        children: [
          _TextTab(
            label: 'JOURNAL',
            active: tab == AppTab.journal,
            markerRadius: const BorderRadius.only(
              topLeft: Radius.circular(3), topRight: Radius.circular(6),
              bottomRight: Radius.circular(4), bottomLeft: Radius.circular(7),
            ),
            rotationDeg: -1,
            onTap: () => onSelect(AppTab.journal),
          ),
          _TextTab(
            label: 'HABITS',
            active: tab == AppTab.habits,
            markerRadius: const BorderRadius.only(
              topLeft: Radius.circular(6), topRight: Radius.circular(3),
              bottomRight: Radius.circular(7), bottomLeft: Radius.circular(4),
            ),
            rotationDeg: .8,
            onTap: () => onSelect(AppTab.habits),
          ),
          _TextTab(
            label: 'SLEEP',
            active: tab == AppTab.sleep,
            markerRadius: const BorderRadius.only(
              topLeft: Radius.circular(4), topRight: Radius.circular(7),
              bottomRight: Radius.circular(3), bottomLeft: Radius.circular(6),
            ),
            rotationDeg: -.6,
            onTap: () => onSelect(AppTab.sleep),
          ),
          SizedBox(
            width: 44,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelect(AppTab.profile),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (tab == AppTab.profile)
                    Positioned(
                      left: 4, right: 4, top: 6, height: 24,
                      child: Transform.rotate(
                        angle: -1.4 * 3.14159265 / 180,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: t.hi,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5), topRight: Radius.circular(8),
                              bottomRight: Radius.circular(4), bottomLeft: Radius.circular(7),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ProfileIcon(
                    size: 24,
                    glyphColor: tab == AppTab.profile ? t.onHi : t.ink,
                    borderColor: tab == AppTab.profile ? t.onHi : t.ink,
                    borderWidth: 1.8,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextTab extends StatelessWidget {
  final String label;
  final bool active;
  final BorderRadius markerRadius;
  final double rotationDeg;
  final VoidCallback onTap;

  const _TextTab({
    required this.label,
    required this.active,
    required this.markerRadius,
    required this.rotationDeg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(2, 7, 2, 8),
          child: SizedBox(
            // Fixed height so the marker below can be positioned relative to
            // a known box instead of guessing where the (font-metric
            // dependent) text glyphs actually land.
            height: 20,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (active)
                  Positioned(
                    left: 8, right: 8, top: 1.5, bottom: 1.5,
                    child: Transform.rotate(
                      angle: rotationDeg * 3.14159265 / 180,
                      child: DecoratedBox(decoration: BoxDecoration(color: t.hi, borderRadius: markerRadius)),
                    ),
                  ),
                Text(label, style: PaperText.tabLabel(active ? t.onHi : t.ink, active: active)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
