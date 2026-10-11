import 'package:flutter/material.dart';

import '../../../domain/faction/faction_personality.dart';
import '../../theme/faction_colors.dart';
import '../common/raster_svg.dart';

/// The emblem of a faction, in its colours. A personality whose emblem is
/// not drawn yet shows a disc of its colour.
class FactionEmblem extends StatelessWidget {
  final FactionPersonality personality;
  final double size;

  const FactionEmblem({super.key, required this.personality, this.size = 40});

  /// Asset of the emblem of [personality], `null` while it has none.
  static String? assetOf(
    FactionPersonality personality,
  ) => switch (personality) {
    FactionPersonality.wreckPillagers =>
      'assets/icons/factions/wreck_pillagers.svg',
    FactionPersonality.pearlOrder => 'assets/icons/factions/pearl_order.svg',
    FactionPersonality.anglerCult => 'assets/icons/factions/angler_cult.svg',
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final String? asset = assetOf(personality);
    if (asset == null) {
      return Icon(
        Icons.circle,
        color: FactionColors.of(personality),
        size: size,
      );
    }
    return RasterSvg(assetPath: asset, size: size);
  }
}
