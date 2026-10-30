import 'package:flutter/painting.dart';

/// Colours of the deep trench seen behind and over an isometric map: the
/// water lit from far above, the light rays, the ridges of the trench
/// walls and the haze of depth.
abstract final class AbyssTrenchTheme {
  /// The water, from the surface side down into the abyss.
  static const water = [
    Color(0xFF16314F),
    Color(0xFF0D1E35),
    Color(0xFF04080F),
  ];
  static const waterStops = [0.0, 0.35, 1.0];

  /// A ray of daylight, fading as it sinks.
  static const ray = [Color(0x29A8F0FF), Color(0x0D7FD8F0), Color(0x007FD8F0)];
  static const rayStops = [0.0, 0.6, 1.0];

  /// The far ridge, from its crest down.
  static const farRidge = [Color(0xD916304C), Color(0xD90A1729)];

  /// The near ridge, from its crest down.
  static const midRidge = [
    Color(0xFF1B3858),
    Color(0xFF0F2239),
    Color(0xFF081322),
  ];

  /// The faint light catching the crests of the far and near ridges.
  static const farRim = Color(0x263E6E9C);
  static const midRim = Color(0x403E6E9C);

  /// Creatures glowing on the trench walls.
  static const speck = Color(0xFF7FFFE0);

  /// The abyss darkening under the ridges.
  static const fall = [Color(0x0003070D), Color(0xE603070D)];

  /// The veil of water between the ridges and the map.
  static const veil = Color(0x400B1A2E);

  /// Depth haze over the map, in screen space: bluish where the eye looks
  /// far (the top of the screen), clear in the middle, darker at the
  /// bottom.
  static const haze = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x8C0E2440),
      Color(0x1F0E2440),
      Color(0x000E2440),
      Color(0x4003070E),
    ],
    stops: [0, 0.3, 0.7, 1],
  );
}
