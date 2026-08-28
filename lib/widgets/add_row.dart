import 'package:flutter/material.dart';

import '../theme/paper_tokens.dart';
import '../theme/text_styles.dart';
import 'pill_button.dart';

/// The underlined-field + pill-button add row shared by tasks, moments and
/// habits. Height is either 20 (tasks) or 40 (moments / habits) to match the
/// grid; the extra height is just vertical centering room, the field itself
/// stays a 20px line.
class AddRow extends StatefulWidget {
  final String? glyph;
  final String hint;
  final String buttonLabel;
  final BorderRadius buttonRadius;
  final double height;
  final ValueChanged<String> onSubmit;

  const AddRow({
    super.key,
    required this.glyph,
    required this.hint,
    required this.buttonLabel,
    required this.buttonRadius,
    required this.onSubmit,
    this.height = 20,
  });

  @override
  State<AddRow> createState() => _AddRowState();
}

class _AddRowState extends State<AddRow> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  void _submit() {
    if (_controller.text.trim().isEmpty) return;
    widget.onSubmit(_controller.text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    return SizedBox(
      height: widget.height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.glyph != null) ...[
            SizedBox(
              width: 20,
              child: Text(widget.glyph!, textAlign: TextAlign.center, style: PaperText.body(t.ink).copyWith(fontSize: 15, color: t.ink.withValues(alpha: t.ink.a * .45))),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: SizedBox(
              height: 20,
              child: Container(
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.ink50, width: 2))),
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  textCapitalization: TextCapitalization.characters,
                  style: PaperText.body(t.ink),
                  cursorColor: t.ink,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: widget.hint.toUpperCase(),
                    hintStyle: PaperText.body(t.ink.withValues(alpha: t.ink.a * .4)),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PillButton(label: widget.buttonLabel, radius: widget.buttonRadius, onTap: _submit),
        ],
      ),
    );
  }
}
