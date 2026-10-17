import 'package:flutter/material.dart';

import '../../theme/abyss_colors.dart';

/// A line of the game's lore, told in dimmed italics, e.g. under the
/// subtitle of an end screen or the title of a chapter.
class LoreText extends StatelessWidget {
  final String text;
  final TextAlign textAlign;

  /// Style to dim and slant; the theme's body text when `null`.
  final TextStyle? style;

  const LoreText(
    this.text, {
    super.key,
    this.textAlign = TextAlign.start,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.bodyMedium;
    return Text(
      text,
      textAlign: textAlign,
      style: (base ?? const TextStyle()).copyWith(
        color: AbyssColors.onSurfaceDim,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
