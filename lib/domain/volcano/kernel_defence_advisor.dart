import '../action/fight_monster_helpers.dart';
import '../fight/army_planner.dart';
import '../fight/combatant.dart';
import '../fight/combatant_builder.dart';
import '../fight/memo_cache.dart';
import '../fight/unit_boost.dart';
import '../game/player.dart';
import '../map/monster_lair.dart';
import '../unit/unit_type.dart';
import 'kernel_garrison.dart';
import 'magma_rampart.dart';

/// Sizes the garrison of the volcanic kernel against an announced kraken
/// wave, as a careful player does: by rehearsing the fight with the
/// garrison and the magma rampart, then adding Harpoonists until the
/// kernel holds with a safety margin, as `RaidDefenceAdvisor` does for
/// the base.
///
/// The rehearsals use [planner]'s own seeded dice, so the advice is the
/// same for the same game and never consumes the game's random stream.
/// Answers are remembered, since the guide asks at every rebuild.
abstract final class KernelDefenceAdvisor {
  /// Wins 19 rehearsals out of 20 at least.
  static const ArmyPlanner planner = ArmyPlanner(
    rehearsals: 20,
    confidence: 0.95,
  );

  /// Most Harpoonists ever advised on top of the garrison.
  static const int maxAdded = 150;

  static final MemoCache<String, int?> _answers = MemoCache<String, int?>(
    capacity: 8,
  );

  /// Units [player] should have in the kernel's garrison against [wave],
  /// counting those already there; `null` when even [maxAdded] more
  /// Harpoonists would not hold.
  static int? unitsFor(Player player, MonsterLair wave) {
    final Map<UnitType, int> garrison = KernelGarrison.of(player);
    final UnitBoost boost = FightMonsterHelpers.unitBoostOf(
      player,
      defendingBase: true,
    );
    final int level = KernelGarrison.kernelLevelOf(player);
    return _answers.get(_keyOf(garrison, wave, boost, level), () {
      final int have = garrison[UnitType.harpoonist] ?? 0;
      final int? added = planner.smallestWinning(
        maxAdded,
        (int k) => <UnitType, int>{...garrison, UnitType.harpoonist: have + k},
        () => CombatantBuilder.monsterCombatantsFrom(wave),
        boost: boost,
        allies: _rampartOf(level),
      );
      if (added == null) return null;
      return garrison.values.fold<int>(added, (int a, int b) => a + b);
    });
  }

  /// Everything the answer depends on.
  static String _keyOf(
    Map<UnitType, int> garrison,
    MonsterLair wave,
    UnitBoost boost,
    int level,
  ) => [
    for (final UnitType type in UnitType.values) garrison[type] ?? 0,
    wave.difficulty.index,
    for (final MapEntry(:key, :value) in wave.groups.entries)
      '${key?.name}:$value',
    boost.atkPercent,
    boost.defPercent,
    boost.hpPercent,
    level,
  ].join('/');

  /// The magma rampart of a kernel at [level], if any.
  static List<Combatant> Function()? _rampartOf(int level) {
    if (MagmaRampart.combatantFor(level) == null) return null;
    return () => <Combatant>[MagmaRampart.combatantFor(level)!];
  }
}
