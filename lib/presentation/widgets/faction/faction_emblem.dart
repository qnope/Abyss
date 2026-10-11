import 'package:flutter/material.dart';

import '../../../domain/faction/faction_personality.dart';
import '../common/raster_svg.dart';

/// The emblem of a faction, a medallion in its colours.
class FactionEmblem extends StatelessWidget {
  final FactionPersonality personality;
  final double size;

  const FactionEmblem({super.key, required this.personality, this.size = 40});

  /// Asset of the emblem of [personality], `null` while it has none.
  static String assetOf(FactionPersonality personality) =>
      'assets/icons/factions/${_files[personality]}.svg';

  static const Map<FactionPersonality, String> _files =
      <FactionPersonality, String>{
        FactionPersonality.wreckPillagers: 'wreck_pillagers',
        FactionPersonality.pearlOrder: 'pearl_order',
        FactionPersonality.anglerCult: 'angler_cult',
        FactionPersonality.murenaHorde: 'murena_horde',
        FactionPersonality.siphonophoreGuild: 'siphonophore_guild',
        FactionPersonality.silenceMonks: 'silence_monks',
        FactionPersonality.currentNomads: 'current_nomads',
        FactionPersonality.pyrosomeHive: 'pyrosome_hive',
        FactionPersonality.magmaSmiths: 'magma_smiths',
        FactionPersonality.krakenFaithful: 'kraken_faithful',
      };

  @override
  Widget build(BuildContext context) =>
      RasterSvg(assetPath: assetOf(personality), size: size);
}
