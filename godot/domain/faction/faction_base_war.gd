class_name FactionBaseWar
extends RefCounted
## lib/domain/faction/faction_base_war.dart: a faction that attacks the
## weakest base it knows and would beat in ArmyPlanner.confidence of its
## rehearsals: another faction at once, the human at the end of the turn,
## without warning.

## Quarters of the army sent to war: the fewest that still win, so that a
## faction does not throw its whole army at a weak base.
const QUARTERS := 4


## Attacks the weakest beatable base; returns whether it attacked. On a
## `grudge` slot the human comes first, and a human it cannot beat is
## skipped rather than ending the search.
static func play(turn: ScriptTurn, planner: ArmyPlanner, grudge: bool) -> bool:
	var me := turn.player
	var army := FactionWar.fighters_on(me, RaidBattle.BASE_LEVEL)
	if army.is_empty():
		return false
	var boost := FightMonsterHelpers.unit_boost_of(me, true)
	var ours := CombatantBuilder.player_combatants_from(army, boost)
	for t: BaseTarget in FactionBaseTargets.weakest_first(turn, ours, grudge):
		if not planner.wins(army, _defence_of(t), boost):
			if grudge and FactionBaseTargets.is_human(turn, t.player):
				continue
			return false
		var sent := _smallest_winning(army, planner, boost, t)
		if _strike(turn, t.player, sent):
			return true
	return false


static func _smallest_winning(
	army: Dictionary[UnitType.Value, int], planner: ArmyPlanner, boost: UnitBoost, target: BaseTarget
) -> Dictionary[UnitType.Value, int]:
	for k: int in range(1, QUARTERS):
		if planner.wins(_part(army, k), _defence_of(target), boost):
			return _part(army, k)
	return army


static func _part(army: Dictionary[UnitType.Value, int], k: int) -> Dictionary[UnitType.Value, int]:
	var part: Dictionary[UnitType.Value, int] = {}
	for type: UnitType.Value in army:
		part[type] = ceili(DartMath.quotient(army[type] * k, QUARTERS))
	return part


## `() => BaseDefence.fromIntel(t.intel).side`.
static func _defence_of(target: BaseTarget) -> Callable:
	return func() -> Array[Combatant]: return BaseDefence.from_intel(target.intel).side


static func _strike(turn: ScriptTurn, target: Player, army: Dictionary[UnitType.Value, int]) -> bool:
	if target.id == turn.game.human_player_id:
		return turn.try_perform(AnnounceAttackAction.new(army, turn.random()))
	return turn.try_perform(AttackBaseAction.new(target.id, army, turn.random()))
