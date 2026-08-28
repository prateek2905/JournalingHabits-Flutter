import 'package:flutter/material.dart';

import '../theme/paper_tokens.dart';
import '../theme/text_styles.dart';

/// 40px section heading row: heading with a 2px ink underline, plus a meta
/// note beside it, bottom-aligned.
class SectionHeader extends StatelessWidget {
  final String heading;
  final String meta;
  final double topPadding;

  const SectionHeader({super.key, required this.heading, required this.meta, this.topPadding = 0});

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: SizedBox(
        height: 40,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: DecoratedBox(
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.ink, width: 2))),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: Text(heading.toUpperCase(), style: PaperText.sectionHeading(t.ink), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(meta.toUpperCase(), style: PaperText.sectionMeta(t.ink)),
          ],
        ),
      ),
    );
  }
}
