import 'package:flutter/painting.dart';

/// Colours of the rock slab an isometric map stands on: its thickness,
/// seen under the map's two front edges, the left face lit by the light
/// falling from the upper left, the right one in shade.
abstract final class AbyssSlabTheme {
  /// The lit left face, from its lip down to its foot.
  static const litFace = [
    Color(0xFF2A4566),
    Color(0xFF1A2E48),
    Color(0xFF060B14),
  ];

  /// The shaded right face, from its lip down to its foot.
  static const shadedFace = [
    Color(0xFF1A2C44),
    Color(0xFF101E31),
    Color(0xFF03060C),
  ];

  /// Where the middle colour of a face lies, down from its lip.
  static const faceStops = [0.0, 0.25, 1.0];

  /// Strata lines of the lit and shaded faces, and the dark groove under
  /// each.
  static const litStratum = Color(0xFF3C5C82);
  static const shadedStratum = Color(0xFF2A4462);
  static const stratumGroove = Color(0xFF02050A);

  /// Stones set in the rock, from the lightest to the darkest.
  static const stoneLight = Color(0xFF2C4466);
  static const stoneDark = Color(0xFF0C1626);

  /// The glint along the top of a stone.
  static const stoneGlint = Color(0x666E8EB4);

  /// Algae hanging over the lip.
  static const strands = [
    Color(0xD91F8A64),
    Color(0xD9176B52),
    Color(0xD92BAF7F),
  ];

  /// Bioluminescent specks glowing in the rock: halo, then core.
  static const speckHalo = Color(0x331DE9B6);
  static const speckGlow = Color(0x801DE9B6);
  static const speckCore = Color(0xFFE8FFF6);

  /// The lit lips of the left and right faces.
  static const litLip = Color(0x8C7FA6D2);
  static const shadedLip = Color(0x8C4E6E96);

  /// The dark of the abyss swallowing the foot of the slab.
  static const underShadow = Color(0x8C02050A);
}
