import '../../game/game.dart';
import '../../game/player.dart';
import '../../map/monster_lair.dart';
import '../../raid/raid_battle.dart';
import '../../raid/raid_defence_advisor.dart';
import '../../unit/unit_type.dart';
import 'guide_advice.dart';
import 'guide_message.dart';
import 'guide_target.dart';

/// What the guide says once the first raid is announced: how many
/// Harpoonists to have on the base level to push it back, as
/// [RaidDefenceAdvisor] sizes them.
abstract final class GuideRaid {
  /// The advice against the raid announced to [player], the halo on
  /// [target]: the Harpoonists, or the end of the turn when they were
  /// already recruited this turn.
  static GuideAdvice of(Game game, Player player, GuideTarget target) {
    final MonsterLair wave = player.raidState.incoming!;
    final int arrival = player.raidState.arrivalTurn!;
    final int monsters = wave.totalCount;
    final int? needed = RaidDefenceAdvisor.harpoonistsFor(player, wave);
    if (needed == null) {
      return GuideAdvice(GuideRaidAlert(arrival, monsters), target);
    }
    final int have = RaidBattle.defendersOf(player)[UnitType.harpoonist] ?? 0;
    if (have >= needed) {
      return GuideAdvice(
        GuideRaidAlert(arrival, monsters, needed: needed),
        const GuideTarget.endTurn(),
      );
    }
    final alert = GuideRaidAlert(
      arrival,
      monsters,
      needed: needed,
      missing: needed - have,
      canRecruit: target.unit == UnitType.harpoonist,
      lastTurn: arrival <= game.turn,
    );
    return GuideAdvice(alert, target);
  }
}
