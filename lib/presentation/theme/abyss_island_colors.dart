import 'package:flutter/painting.dart';

/// Colours of the player's base drawn as an island in the abyss: the
/// rock of the spire under it, its coral rampart, the descent cable, its
/// walkways, the pads under its buildings and the ghost of a building
/// still to build.
/// Taken from the approved mockup.
abstract final class AbyssIslandColors {
  // The rock of the spire under the slab, lit from the left.
  static const Color litRockTop = Color(0xFF2A4566);
  static const Color litRockDeep = Color(0xFF16283F);
  static const Color shadedRockTop = Color(0xFF1A2C44);
  static const Color shadedRockDeep = Color(0xFF0E1A2C);
  static const Color ledge = Color(0xFF5B7FAA);
  static const Color crevice = Color(0xFF02050A);
  static const Color glowCore = Color(0xFFE8FFF6);
  static const List<Color> roots = [
    Color(0xFF1F8A64),
    Color(0xFF176B52),
    Color(0xFF2BAF7F),
  ];

  // The coral rampart: its top, its lit and shaded faces from the top
  // down, the pores in them and the glowing polyps over them.
  static const List<Color> coralTop = [Color(0xFFFF9EB8), Color(0xFFD9466E)];
  static const List<Color> coralLitFace = [
    Color(0xFFB8345A),
    Color(0xFF4A1024),
  ];
  static const List<Color> coralShadedFace = [
    Color(0xFF8E2546),
    Color(0xFF2E0816),
  ];
  static const Color coralPore = Color(0xB32E0816);
  static const Color polyp = Color(0xFFFF9EB8);
  static const Color polypGlow = Color(0xFFFF6E91);

  // The descent cable, its cabin and the blue glow far below.
  static const Color cable = Color(0xFF8FA9C6);
  static const Color cabin = Color(0xFF1A2B44);
  static const Color cabinRim = Color(0xFF448AFF);
  static const Color cabinLight = Color(0xFFBBDEFB);
  static const Color cabinBeam = Color(0x1482B1FF);
  static const Color deepGlow = Color(0x59448AFF);

  // The metal walkways between the buildings.
  static const Color walkLight = Color(0xFF46668E);
  static const Color walkDark = Color(0xFF2A4266);
  static const Color slat = Color(0xFF0F1C2E);
  static const Color walkShadow = Color(0xFF03080F);
  static const Color lampCore = Color(0xFFE0FFFF);
  static const Color walkRim = Color(0xFF7FD8F0);

  // The pads the buildings stand on, from the plot to the lit deck.
  static const Color plot = Color(0xFF00E5FF);
  static const Color stake = Color(0xFF7B9CC0);
  static const Color stakeShadow = Color(0xFF02060D);
  static const Color gravelLight = Color(0xFF3D5677);
  static const Color gravelDark = Color(0xFF22364F);
  static const Color pebbleLight = Color(0xFF5E7DA3);
  static const Color pebbleDark = Color(0xFF1A2B44);
  static const Color gravelRim = Color(0xFF8FB0D8);
  static const Color padLitTop = Color(0xFF2C4361);
  static const Color padLitBottom = Color(0xFF13213A);
  static const Color padShadedTop = Color(0xFF1A2B44);
  static const Color padShadedBottom = Color(0xFF0A1424);
  static const Color deckLight = Color(0xFF5A7699);
  static const Color deckMid = Color(0xFF3A5374);
  static const Color deckDark = Color(0xFF22374F);
  static const Color seam = Color(0xFF16263D);
  static const Color rivet = Color(0xFF9DB6D2);
  static const Color deckRim = Color(0xFFC8DCF2);
  static const Color beaconCore = Color(0xFFFFFFFF);

  /// Share of a sprite's alpha its cyan [ghost] keeps.
  static const double ghostAlpha = 0.42;

  /// Turns a building still to build into a translucent cyan ghost.
  static const ColorFilter ghost = ColorFilter.matrix([
    0, 0, 0, 0, 64, //
    0.2, 0.3, 0.3, 0, 191, //
    0.25, 0.3, 0.35, 0, 230, //
    0, 0, 0, ghostAlpha, 0,
  ]);

  /// Greys a degraded building: barely saturated, darkened, cold.
  static const ColorFilter degraded = ColorFilter.matrix([
    0.2053, 0.3768, 0.0379, 0, 0, //
    0.1195, 0.5001, 0.0404, 0, 0, //
    0.1340, 0.4497, 0.1563, 0, 0, //
    0, 0, 0, 1, 0,
  ]);
}
