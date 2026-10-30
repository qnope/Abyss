import 'package:flutter/painting.dart';

/// Colours of the player's base drawn as an island in the abyss: the
/// water behind it, the rock of its slab and spire, its walkways and the
/// ghost of a building still to build. Taken from the approved mockup.
abstract final class AbyssIslandColors {
  // The water behind the island, from the surface light to the dark.
  static const Color waterTop = Color(0xFF16314F);
  static const Color waterMid = Color(0xFF0D1E35);
  static const Color waterBottom = Color(0xFF04080F);
  static const Color ray = Color(0xFFA8F0FF);
  static const Color rayFade = Color(0xFF7FD8F0);
  static const Color haze = Color(0xFF0B1A2E);
  static const Color abyssFall = Color(0xFF03070D);

  // The far walls of the trench.
  static const Color farRidgeTop = Color(0xFF16304C);
  static const Color farRidgeBottom = Color(0xFF0A1729);
  static const Color midRidgeLit = Color(0xFF1B3858);
  static const Color midRidge = Color(0xFF0F2239);
  static const Color midRidgeDark = Color(0xFF081322);
  static const Color ridgeRim = Color(0xFF3E6E9C);
  static const Color speck = Color(0xFF7FFFE0);

  // The rock of the slab and of the spire, lit from the left.
  static const Color litRockTop = Color(0xFF2A4566);
  static const Color litRockMid = Color(0xFF1A2E48);
  static const Color litRockDeep = Color(0xFF16283F);
  static const Color litRockBottom = Color(0xFF060B14);
  static const Color shadedRockTop = Color(0xFF1A2C44);
  static const Color shadedRockMid = Color(0xFF101E31);
  static const Color shadedRockDeep = Color(0xFF0E1A2C);
  static const Color shadedRockBottom = Color(0xFF03060C);
  static const Color litStrata = Color(0xFF3C5C82);
  static const Color shadedStrata = Color(0xFF2A4462);
  static const Color ledge = Color(0xFF5B7FAA);
  static const Color crevice = Color(0xFF02050A);
  static const Color stoneLight = Color(0xFF2C4466);
  static const Color stoneDark = Color(0xFF0C1626);
  static const Color litLip = Color(0xFF7FA6D2);
  static const Color shadedLip = Color(0xFF4E6E96);
  static const Color glowCore = Color(0xFFE8FFF6);
  static const List<Color> roots = [
    Color(0xFF1F8A64),
    Color(0xFF176B52),
    Color(0xFF2BAF7F),
  ];

  // The metal walkways between the buildings.
  static const Color walkLight = Color(0xFF46668E);
  static const Color walkDark = Color(0xFF2A4266);
  static const Color slat = Color(0xFF0F1C2E);
  static const Color walkShadow = Color(0xFF03080F);
  static const Color lampCore = Color(0xFFE0FFFF);

  /// Turns a building still to build into a translucent cyan ghost.
  static const ColorFilter ghost = ColorFilter.matrix([
    0, 0, 0, 0, 64, //
    0.2, 0.3, 0.3, 0, 191, //
    0.25, 0.3, 0.35, 0, 230, //
    0, 0, 0, 0.23, 0,
  ]);
}
