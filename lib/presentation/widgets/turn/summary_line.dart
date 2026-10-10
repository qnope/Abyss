import 'package:flutter/material.dart';

/// One colored line of the end-of-turn summary: an icon and its text.
class SummaryLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  /// The text styled piece by piece, when the line is [SummaryLine.rich].
  final InlineSpan? span;

  const SummaryLine(this.icon, this.text, this.color, {super.key})
    : span = null;

  /// A line whose pieces of text are styled on their own, over [color].
  SummaryLine.rich(this.icon, InlineSpan this.span, this.color, {super.key})
    : text = span.toPlainText();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(color: color);
    final span = this.span;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child:
                span == null
                    ? Text(text, style: style)
                    : Text.rich(span, style: style),
          ),
        ],
      ),
    );
  }
}
