import '../game/player.dart';
import '../map/grid_position.dart';
import '../raid/raid_battle.dart';
import '../script/script_turn.dart';
import '../script/strategies/recruit_moves.dart';
import '../unit/unit_type.dart';
import 'faction_traits.dart';

/// A faction arms for war with its personality's own mix of units, within
/// the share of the stocks the personality gives it. A type its barracks
/// does not train yet, or that it already recruited this turn, is left out
/// of the mix.
///
/// It only arms while it has seen the base of someone else: a faction
/// alone has nobody to fight, and its stocks go to the race.
abstract final class FactionWarRecruit {
  static void play(ScriptTurn turn, FactionTraits traits) {
    final double share = traits.shareOn(turn.number);
    if (share <= 0 || !_knowsARival(turn)) return;
    final Map<UnitType, int> mix = <UnitType, int>{
      for (final MapEntry<UnitType, int> e in traits.warMix.entries)
        if (turn.usableMixes(<Map<UnitType, int>>[
          <UnitType, int>{e.key: 1},
        ]).isNotEmpty)
          e.key: e.value,
    };
    if (mix.isEmpty) return;
    final int k = turn.affordable(mix, share: share);
    if (k > 0) turn.recruitMix(mix, k);
  }

  static bool _knowsARival(ScriptTurn turn) {
    final Set<GridPosition> seen =
        turn.player.revealedCellsOnLevel(RaidBattle.baseLevel).toSet();
    return turn.game.players.values.any(
      (Player p) =>
          p.id != turn.player.id &&
          !p.hasFallen &&
          seen.contains(GridPosition(x: p.baseX, y: p.baseY)),
    );
  }
}
