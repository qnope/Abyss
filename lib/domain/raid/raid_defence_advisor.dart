import '../action/fight_monster_helpers.dart';
import '../building/coral_citadel_rampart.dart';
import '../fight/army_planner.dart';
import '../fight/combatant.dart';
import '../fight/combatant_builder.dart';
import '../fight/unit_boost.dart';
import '../game/player.dart';
import '../map/monster_lair.dart';
import '../unit/unit_type.dart';
import 'raid_battle.dart';

/// Sizes the defence of the base against an announced raid wave, the way
/// a careful player does: by rehearsing the fight with the units standing
/// on the base level and the Coral Citadel rampart, then adding
/// Harpoonists until the base wins with a safety margin.
///
/// The rehearsals use [planner]'s own seeded dice, derived from the army
/// rehearsed, so the advice is the same for the same game and never
/// consumes the game's random stream. The last answer is kept, since
/// the guide asks again at every rebuild of the screen.
abstract final class RaidDefenceAdvisor {
  /// Wins 19 rehearsals out of 20 at least.
  static const ArmyPlanner planner = ArmyPlanner(
    rehearsals: 20,
    confidence: 0.95,
  );

  /// Most Harpoonists ever advised on top of the defenders.
  static const int maxAdded = 150;

  /// Harpoonists [player] should have on the base level against [wave],
  /// counting those already there; `null` when even [maxAdded] more would
  /// not hold.
  static int? harpoonistsFor(Player player, MonsterLair wave) {
    final Map<UnitType, int> base = RaidBattle.defendersOf(player);
    final UnitBoost boost =
        FightMonsterHelpers.unitBoostOf(player, defendingBase: true);
    final Combatant? rampart =
        CoralCitadelRampart.combatantOf(player.buildings);
    final String key = _keyOf(base, wave, boost, rampart);
    if (key == _lastKey) return _lastAnswer;
    final int have = base[UnitType.harpoonist] ?? 0;
    final int? added = planner.smallestWinning(
      maxAdded,
      (int k) => <UnitType, int>{...base, UnitType.harpoonist: have + k},
      () => CombatantBuilder.monsterCombatantsFrom(wave),
      boost: boost,
      allies: _rampartOf(player),
    );
    _lastKey = key;
    return _lastAnswer = added == null ? null : have + added;
  }

  static String? _lastKey;
  static int? _lastAnswer;

  /// Everything the answer depends on.
  static String _keyOf(Map<UnitType, int> base, MonsterLair wave,
          UnitBoost boost, Combatant? rampart) =>
      [
        for (final UnitType type in UnitType.values) base[type] ?? 0,
        wave.difficulty.index,
        for (final MapEntry(:key, :value) in wave.groups.entries)
          '${key?.name}:$value',
        boost.atkPercent,
        boost.defPercent,
        boost.hpPercent,
        rampart?.maxHp,
        rampart?.def,
      ].join('/');

  /// The Coral Citadel rampart that backs [player]'s base, if built.
  static List<Combatant> Function()? _rampartOf(Player player) {
    if (CoralCitadelRampart.combatantOf(player.buildings) == null) return null;
    return () =>
        <Combatant>[CoralCitadelRampart.combatantOf(player.buildings)!];
  }
}
