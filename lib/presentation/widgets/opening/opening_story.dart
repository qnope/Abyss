import 'package:flutter/material.dart';

import '../../../domain/building/building_type.dart';
import '../../../domain/map/monster_difficulty.dart';
import '../../../domain/map/monster_family.dart';
import '../../extensions/building_type_extensions.dart';
import '../../extensions/monster_family_extensions.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_extension.dart';
import '../backdrop/abyss_backdrop.dart';
import '../backdrop/backdrop_image.dart';
import '../common/raster_svg.dart';
import '../guide/guide_bubble.dart';
import 'story_page.dart';
import 'story_pager.dart';

/// Opens the opening story in a dialog, e.g. from the settings, the last
/// card closing it; completes once it is closed.
Future<void> showOpeningStory(BuildContext context) => showDialog<void>(
  context: context,
  builder:
      (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: StoryPager(
          pages: openingStoryPages(context.l10n),
          doneLabel: context.l10n.commonClose,
          onDone: () => Navigator.pop(context),
        ),
      ),
);

/// The story told by the octopus archivist as a game begins: the Great
/// Sinking, the abyss that listens, the cold Core, then the goal.
List<StoryPage> openingStoryPages(AppLocalizations l10n) => [
  StoryPage(
    picture: const _ColonyOnTheReef(),
    title: l10n.openingSinkingTitle,
    lines: [l10n.openingSinkingLine1, l10n.openingSinkingLine2],
  ),
  StoryPage(
    picture: _sprite(MonsterFamily.swarm.svgPathAt(MonsterDifficulty.hard)),
    title: l10n.openingListensTitle,
    lines: [l10n.openingListensLine1, l10n.openingListensLine2],
  ),
  StoryPage(
    picture: _sprite(BuildingType.volcanicKernel.iconPath),
    title: l10n.openingCoreTitle,
    lines: [l10n.openingCoreLine1, l10n.openingCoreLine2],
  ),
  StoryPage(
    picture: _sprite(GuideBubble.portraitPath),
    title: l10n.openingGoalTitle,
    lines: [l10n.openingGoalLine1, l10n.openingGoalLine2],
  ),
];

/// Side of a sprite in its card, a little under the frame's height.
const double _spriteSize = 160;

Widget _sprite(String asset) =>
    Center(child: RasterSvg(assetPath: asset, size: _spriteSize));

/// The menu backdrop cropped around the colony dome on its reef, under
/// the light still falling from above.
class _ColonyOnTheReef extends StatelessWidget {
  const _ColonyOnTheReef();

  /// Point of the backdrop kept in view: a little above the dome, so the
  /// light rays show above it and the reef below.
  static const _focus = Offset(800, 1050);

  @override
  Widget build(BuildContext context) =>
      const BackdropImage(asset: AbyssBackdrop.defaultAsset, focus: _focus);
}
