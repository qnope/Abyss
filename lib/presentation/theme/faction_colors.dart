import 'package:flutter/material.dart';

import '../../domain/faction/faction_personality.dart';

/// The colour of each faction: on the map, in the ranking. Ten hues far
/// from each other and from the cyan of the human's posts.
abstract final class FactionColors {
  static Color of(FactionPersonality personality) => switch (personality) {
        FactionPersonality.wreckPillagers => const Color(0xFFFF7043),
        FactionPersonality.pearlOrder => const Color(0xFFF5F5F5),
        FactionPersonality.anglerCult => const Color(0xFFB388FF),
        FactionPersonality.murenaHorde => const Color(0xFF66BB6A),
        FactionPersonality.siphonophoreGuild => const Color(0xFFFF80AB),
        FactionPersonality.silenceMonks => const Color(0xFF90A4AE),
        FactionPersonality.currentNomads => const Color(0xFFFFD740),
        FactionPersonality.pyrosomeHive => const Color(0xFF26A69A),
        FactionPersonality.magmaSmiths => const Color(0xFFE53935),
        FactionPersonality.krakenFaithful => const Color(0xFF5C6BC0),
      };
}
