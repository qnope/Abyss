import 'package:flutter/widgets.dart';

import '../../theme/abyss_menu_theme.dart';

/// A screen title glowing like bioluminescence, with an optional subtitle
/// in small capitals below. Both shrink to fit a narrow box.
///
/// Sits behind its own repaint boundary, so a button ripple nearby does
/// not record its glyphs and shadows again. It does not spare the blur:
/// with no raster cache (Impeller, CanvasKit), the glow is still blurred
/// on every frame drawn.
class GlowTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const GlowTitle({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SpacedLine(
            title,
            style: AbyssMenuTheme.heroTitle,
            spacing: AbyssMenuTheme.titleSpacing,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 10),
            _SpacedLine(
              subtitle.toUpperCase(),
              style: AbyssMenuTheme.heroSubtitle,
              spacing: AbyssMenuTheme.subtitleSpacing,
            ),
          ],
        ],
      ),
    );
  }
}

/// One line of widely spaced letters, truly centred: the spacing added
/// after the last letter is balanced before the first one.
class _SpacedLine extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double spacing;

  const _SpacedLine(this.text, {required this.style, required this.spacing});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Padding(
        padding: EdgeInsets.only(left: spacing),
        child: Text(text, maxLines: 1, softWrap: false, style: style),
      ),
    );
  }
}
