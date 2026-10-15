import 'dart:ui';

import '../../../../domain/faction/faction_attack_report.dart';
import '../../../../domain/fight/combatant_builder.dart';
import '../../../../domain/game/game.dart';
import '../../../../domain/map/volcanic_kernel_placer.dart';
import '../../../../domain/unit/unit_type.dart';
import '../../../../domain/volcano/kernel_garrison.dart';
import '../../../extensions/monster_family_extensions.dart';
import '../../../extensions/unit_type_extensions.dart';
import '../../../theme/abyss_colors.dart';
import '../../../theme/faction_colors.dart';
import '../../../widgets/map/effects/story/map_siege.dart';
import '../../../widgets/map/effects/strike/strike_lead.dart';
import '../../../widgets/map/effects/strike/strike_round.dart';
import 'story_chapter.dart';
import 'story_places.dart';

/// The chapter of [attack], an attack of a faction (or of the guardians)
/// on the human in [game]: a siege of the base, of the post or of the
/// volcano attacked, on its level. `null` when no map holds the place.
StoryChapter? attackChapter(Game game, FactionAttackReport attack) {
  final human = game.humanPlayer;
  final (level, place, span) = switch (attack.target) {
    AttackTarget.base => (1, (human.baseX, human.baseY), 1),
    AttackTarget.kernel => (
        KernelGarrison.volcanoLevel,
        StoryPlaces.kernelOf(
            game.levels[KernelGarrison.volcanoLevel], human.id),
        VolcanicKernelPlacer.side,
      ),
    AttackTarget.post => _onPost(game, attack),
  };
  if (place == null) return null;
  return StoryChapter(
    level: level,
    effect: MapSiege(
      place: place,
      span: span,
      victory: !attack.entry.victory,
      attackerSprite: attackerSpriteOf(attack),
      attackerRing: attackerRingOf(attack),
      rounds: defenceRoundsOf(attack.entry.fightResult),
    ),
  );
}

/// The level and the cell of the post [attack] struck, spanning one cell.
(int, (int, int)?, int) _onPost(Game game, FactionAttackReport attack) {
  final post = attack.post;
  final found = post == null ? null : StoryPlaces.postOf(game, post);
  return (found?.$1 ?? 1, found?.$2, 1);
}

/// What stands for the attackers of [attack]: the icon of the unit they
/// sent the most of, or a monster for the guardians, who send none.
String attackerSpriteOf(FactionAttackReport attack) {
  final sent = <UnitType, int>{};
  for (final c in attack.entry.fightResult.initialPlayerCombatants) {
    final type = CombatantBuilder.unitTypeFromKey(c.typeKey);
    if (type != null) sent[type] = (sent[type] ?? 0) + 1;
  }
  return strikeLeadOf(sent)?.iconPath ?? krakenSvgPath;
}

/// The colour of the faction behind [attack]; red for the guardians.
Color attackerRingOf(FactionAttackReport attack) => switch (attack.personality) {
      final personality? => FactionColors.of(personality),
      null => AbyssColors.error,
    };
