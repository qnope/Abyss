import 'package:flutter/material.dart';

import '../../theme/abyss_colors.dart';
import 'raster_svg.dart';

/// Dialog of a card with a picture: its [illustration], its [title], a
/// few short [lines] then its [actions], stacked full width.
class IllustratedCard extends StatelessWidget {
  final String illustration;
  final String title;
  final List<String> lines;
  final List<Widget> actions;

  const IllustratedCard({
    super.key,
    required this.illustration,
    required this.title,
    required this.lines,
    required this.actions,
  });

  static const double illustrationSize = 160;

  @override
  Widget build(BuildContext context) => Dialog(
    child: IllustratedCardBody(
      illustration: illustration,
      title: title,
      lines: lines,
      actions: actions,
    ),
  );
}

/// What an [IllustratedCard] holds, without its dialog: for a card that
/// brings its own frame.
class IllustratedCardBody extends StatelessWidget {
  final String illustration;
  final String title;
  final List<String> lines;
  final List<Widget> actions;

  const IllustratedCardBody({
    super.key,
    required this.illustration,
    required this.title,
    required this.lines,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: RasterSvg(
              assetPath: illustration,
              size: IllustratedCard.illustrationSize,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: text.headlineSmall?.copyWith(color: AbyssColors.biolumCyan),
          ),
          const SizedBox(height: 8),
          for (final line in lines)
            Text(
              line,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: AbyssColors.onSurfaceDim),
            ),
          const SizedBox(height: 16),
          ...actions,
        ],
      ),
    );
  }
}
