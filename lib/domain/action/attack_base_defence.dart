import 'dart:math';

import '../building/coral_citadel_rampart.dart';
import '../fight/casualty_calculator.dart';
import '../fight/casualty_split.dart';
import '../fight/combat_side.dart';
import '../fight/combatant.dart';
import '../fight/combatant_builder.dart';
import '../game/player.dart';
import '../raid/raid_battle.dart';
import '../unit/unit_type.dart';
import 'fight_monster_helpers.dart';

/// What a base fielded against an attack, and what became of it.
class DefenceOutcome {
  /// The units that defended, by type.
  final Map<UnitType, int> engaged;
  final Map<UnitType, int> survivorsIntact;
  final Map<UnitType, int> wounded;
  final Map<UnitType, int> dead;

  /// The defenders as they entered the fight, rampart included.
  final List<Combatant> initial;

  const DefenceOutcome({
    required this.engaged,
    required this.survivorsIntact,
    required this.wounded,
    required this.dead,
    required this.initial,
  });
}

/// The defence of a base against a player: every unit standing on the base
/// level and the Citadel rampart (halved when degraded), as in a raid.
///
/// They fight on the monsters' side of the [FightEngine], the attackers
/// on the player's; a unit keeps its role (a Gardien still draws the
/// blows) on either side.
class BaseDefence {
  final Map<UnitType, int> engaged;

  /// The combatants of the fight; the engine wears them down in place.
  final List<Combatant> side;

  BaseDefence._(this.engaged, this.side);

  factory BaseDefence.of(Player target) {
    final Map<UnitType, int> engaged = RaidBattle.defendersOf(target);
    final Combatant? rampart = CoralCitadelRampart.combatantOf(
      target.buildings,
    );
    return BaseDefence._(engaged, <Combatant>[
      ...CombatantBuilder.playerCombatantsFrom(
        engaged,
        boost: FightMonsterHelpers.unitBoostOf(target, defendingBase: true),
        side: CombatSide.monster,
      ),
      if (rampart != null) _onDefendersSide(rampart),
    ]);
  }

  /// A fresh copy of [c] on the defenders' side, at full health.
  static Combatant _onDefendersSide(Combatant c) => Combatant(
    side: CombatSide.monster,
    typeKey: c.typeKey,
    maxHp: c.maxHp,
    atk: c.atk,
    def: c.def,
  );

  /// Sends the survivors and the wounded back to the base once the fight
  /// is over; the dead are gone.
  DefenceOutcome settle(Player target, {Random? random}) {
    final double pctLost = FightMonsterHelpers.computePctLost(side, side);
    final List<Combatant> alive = <Combatant>[];
    final List<Combatant> fallen = <Combatant>[];
    for (final Combatant c in side) {
      (c.isAlive ? alive : fallen).add(c);
    }
    final CasualtySplit split = CasualtyCalculator(
      random: random,
    ).partition(fallen, pctLost);
    for (final UnitType type in engaged.keys) {
      target.unitsOnLevel(RaidBattle.baseLevel)[type]!.count = 0;
    }
    FightMonsterHelpers.restoreToStock(
      target,
      alive,
      level: RaidBattle.baseLevel,
    );
    FightMonsterHelpers.restoreToStock(
      target,
      split.wounded,
      level: RaidBattle.baseLevel,
    );
    return DefenceOutcome(
      engaged: engaged,
      survivorsIntact: FightMonsterHelpers.combatantsByType(alive),
      wounded: FightMonsterHelpers.combatantsByType(split.wounded),
      dead: FightMonsterHelpers.combatantsByType(split.dead),
      initial: <Combatant>[for (final Combatant c in side) _onDefendersSide(c)],
    );
  }
}
