import '../action/recruit_unit_action.dart';
import '../raid/raid_battle.dart';
import '../script/script_turn.dart';
import '../script/strategies/scout_moves.dart';
import '../unit/unit_type.dart';
import 'faction_personality.dart';
import 'faction_scouting.dart';
import 'faction_traits.dart';

/// A faction spies before it strikes: it keeps a Scout at home for its
/// war slot, whatever the exploration left.
abstract final class FactionSpyScout {
  /// Recruits the Scout of the slot when none is home. A unit type is
  /// recruited once a turn, so the recruit also takes what the
  /// exploration needs, or the scouting would wait a turn; a faction
  /// too poor for all of it still takes the one Scout.
  static void keep(ScriptTurn turn, FactionPersonality personality) {
    final int home = turn.player
            .unitsOnLevel(RaidBattle.baseLevel)[UnitType.scout]
            ?.count ??
        0;
    if (home > 0) return;
    final int need = turn.scoutsWanted(
      explorers: FactionTraits.of(personality).explorers,
      deepScouts: FactionScouting.deepScoutsOf(personality),
      scoutsAhead: true,
    );
    if (need > 0 && _recruit(turn, need + 1)) return;
    _recruit(turn, 1);
  }

  static bool _recruit(ScriptTurn turn, int quantity) => turn.tryPerform(
    RecruitUnitAction(unitType: UnitType.scout, quantity: quantity),
  );
}
