import 'package:flutter/material.dart';

import '../../../domain/game/save_outcome.dart';
import '../../../domain/game/save_summary.dart';
import '../../extensions/save_summary_extensions.dart';
import '../../theme/abyss_card_theme.dart';
import '../../theme/abyss_colors.dart';
import '../common/raster_svg.dart';
import 'save_card_details.dart';
import 'save_card_menu.dart';

/// A saved game in the load list: the depth it reached pictured on the
/// left, its details on the right and its options in the corner.
///
/// A lost game is greyed out by its own colors and a greyscale bitmap,
/// never through a compositing layer.
class SaveCard extends StatelessWidget {
  final SaveSummary summary;

  /// The time the last played date is told against.
  final DateTime now;

  /// Glows, for the game the player most likely resumes.
  final bool highlighted;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  static const double thumbnailSize = 76;
  static const _radius = BorderRadius.all(
    Radius.circular(AbyssCardTheme.savePanelRadius),
  );

  const SaveCard({
    super.key,
    required this.summary,
    required this.now,
    required this.onTap,
    required this.onDelete,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final faded = summary.outcome == SaveOutcome.defeat;
    // The panel is drawn under the material, not as its ink: ink is
    // clipped to the card, which would cut its glow.
    return DecoratedBox(
      decoration: AbyssCardTheme.savePanel(
        highlighted: highlighted,
        faded: faded,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: _radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: _radius,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    RasterSvg(
                      assetPath: summary.thumbnail,
                      size: thumbnailSize,
                      greyscale: faded,
                      opacity: faded ? AbyssColors.unavailableOpacity : 1,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SaveCardDetails(
                        summary: summary,
                        now: now,
                        faded: faded,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: SaveCardMenu(onDelete: onDelete),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
