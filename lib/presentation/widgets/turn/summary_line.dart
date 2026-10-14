import 'package:flutter/material.dart';

import '../common/raster_svg.dart';

/// One colored line of the end-of-turn summary: an icon and its text.
class SummaryLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  /// The text styled piece by piece, when the line is [SummaryLine.rich].
  final InlineSpan? span;

  /// SVG drawn instead of [icon], such as the post a faction attacked.
  final String? illustration;

  const SummaryLine(
    this.icon,
    this.text,
    this.color, {
    super.key,
    this.illustration,
  }) : span = null;

  /// A line whose pieces of text are styled on their own, over [color].
  SummaryLine.rich(this.icon, InlineSpan this.span, this.color, {super.key})
    : text = span.toPlainText(),
      illustration = null;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(color: color);
    final span = this.span;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          if (illustration case final String art)
            RasterSvg(assetPath: art, size: 20)
          else
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
