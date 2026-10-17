import 'package:flutter/material.dart';

import '../../theme/abyss_colors.dart';
import '../common/lore_text.dart';
import 'story_page.dart';

/// A card of a story: the picture of its [page] in a wide frame, its
/// title, its lines told as lore, then its [footer], stacked full width.
class StoryCard extends StatelessWidget {
  final StoryPage page;
  final List<Widget> footer;

  const StoryCard({super.key, required this.page, required this.footer});

  static const double pictureHeight = 180;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    return Material(
      color: theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface,
      shape: theme.dialogTheme.shape,
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _frame(),
            const SizedBox(height: 14),
            Text(
              page.title,
              textAlign: TextAlign.center,
              style: text.headlineSmall?.copyWith(
                color: AbyssColors.biolumCyan,
              ),
            ),
            const SizedBox(height: 10),
            for (final line in page.lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: LoreText(
                  line,
                  textAlign: TextAlign.center,
                  style: text.bodyLarge,
                ),
              ),
            const SizedBox(height: 10),
            ...footer,
          ],
        ),
      ),
    );
  }

  Widget _frame() => Container(
    height: pictureHeight,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      gradient: const RadialGradient(
        colors: [AbyssColors.trench, AbyssColors.abyssBlack],
        radius: 0.9,
      ),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AbyssColors.biolumCyan.withValues(alpha: 0.25)),
    ),
    child: page.picture,
  );
}
