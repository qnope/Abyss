class_name FightResult
extends RefCounted
## lib/domain/fight/fight_result.dart: how a fight ended, turn by turn.

var winner: CombatSide.Value
var turn_count: int
var turn_summaries: Array[FightTurnSummary]
## The player's side as it entered the fight, each at full health.
var initial_player_combatants: Array[Combatant]
## The player's side as the fight left it: the very combatants it was given.
var final_player_combatants: Array[Combatant]
var initial_monster_count: int
var final_monster_count: int


func _init(
	winner_: CombatSide.Value,
	turn_count_: int,
	turn_summaries_: Array[FightTurnSummary],
	initial_player_combatants_: Array[Combatant],
	final_player_combatants_: Array[Combatant],
	initial_monster_count_: int,
	final_monster_count_: int,
) -> void:
	winner = winner_
	turn_count = turn_count_
	turn_summaries = turn_summaries_
	initial_player_combatants = initial_player_combatants_
	final_player_combatants = final_player_combatants_
	initial_monster_count = initial_monster_count_
	final_monster_count = final_monster_count_


func is_victory() -> bool:
	return winner == CombatSide.Value.PLAYER
