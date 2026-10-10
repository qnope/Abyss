import 'package:flutter/material.dart';

import '../../../domain/faction/faction.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/player.dart';
import '../../../domain/raid/announced_attack.dart';
import '../../theme/abyss_colors.dart';
import '../../theme/faction_colors.dart';
import 'faction_attack_banner.dart';

/// One banner per attack of a faction announced on the base of [player];
/// nothing at all while none is coming.
class FactionAttackBars extends StatelessWidget {
  final Game game;
  final Player player;

  const FactionAttackBars({
    super.key,
    required this.game,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    final attacks = player.raidState.attacks;
    if (attacks.isEmpty) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final attack in attacks)
          _banner(attack, _factionOf(attack.attackerId)),
      ],
    );
  }

  Faction? _factionOf(String attackerId) =>
      game.factions.where((f) => f.id == attackerId).firstOrNull;

  Widget _banner(AnnouncedAttack attack, Faction? faction) =>
      FactionAttackBanner(
        attack: attack,
        factionName:
            faction?.name ?? game.players[attack.attackerId]?.name ?? '?',
        color:
            faction == null
                ? AbyssColors.error
                : FactionColors.of(faction.personality),
        currentTurn: game.turn,
      );
}
