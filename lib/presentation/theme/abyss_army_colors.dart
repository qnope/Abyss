import 'package:flutter/painting.dart';

import '../../domain/unit/unit_type.dart';
import 'abyss_colors.dart';

/// Colours of the army's parade ground, an island of the abyss like the
/// base (see [AbyssIslandColors] for its rock, floor and pads): the
/// bright hue each squad paints on its drill pad, the crest in the middle
/// and the depot in front. Taken from the approved mockup.
abstract final class AbyssArmyColors {
  /// The hue of a squad: the ring on its pad, later its banner and plaque.
  /// Brighter than [UnitTypeExtensions.color], which tints cards and
  /// portraits, so that it reads on the dark deck.
  static Color of(UnitType type) => switch (type) {
        UnitType.scout => AbyssColors.biolumBlue,
        UnitType.harpoonist => const Color(0xFFFF7A33),
        UnitType.guardian => const Color(0xFFB0BEC5),
        UnitType.domeBreaker => const Color(0xFFFF9100),
        UnitType.abyssAdmiral => AbyssColors.biolumPurple,
        UnitType.saboteur => AbyssColors.algaeGreen,
      };

  // The crest: a trident in a ring painted on a deck in the middle.
  static const Color crestLight = AbyssColors.biolumCyan;
  static const Color crestSheen = Color(0xFFE0FFFF);
  static const Color crestShadow = Color(0xFF02060D);

  // The boot scuffs on a drill pad.
  static const Color scuff = Color(0xFF1A2B44);

  // The crates of the depot: wood, steel and dark wood, their faces lit
  // from the left, their tops and the paint marked on them.
  static const Color crateWood = Color(0xFF5D4037);
  static const Color crateWoodTop = Color(0xFF8D6E63);
  static const Color crateSteel = Color(0xFF455A64);
  static const Color crateSteelTop = Color(0xFF78909C);
  static const Color crateDark = Color(0xFF4E342E);
  static const Color crateDarkTop = Color(0xFF795548);
  static const Color crateEdge = AbyssColors.abyssBlack;
  static const Color crateStrap = Color(0xFF2E1A12);
  static const Color markOrange = Color(0xFFFF9100);
  static const Color markYellow = AbyssColors.energyYellow;

  // The harpoon rack and the lamp post of the depot.
  static const Color harpoonShaft = Color(0xFF3A2210);
  static const Color harpoonTip = Color(0xFFB0BEC5);
  static const Color rackBar = Color(0xFF5D4037);
  static const List<Color> poleMetal = [
    Color(0xFFCFD8DC),
    Color(0xFF78909C),
    Color(0xFF37474F),
  ];
  static const Color lampGlass = Color(0xFFE0FFFF);
  static const Color lampFrame = Color(0xFF37474F);
}
