class_name FightTurnSummary
extends RefCounted
## lib/domain/fight/fight_turn_summary.dart: what one turn of a fight did,
## for its report.

var turn_number: int
var attacks_played: int
var crit_count: int
var damage_dealt_by_player: int
var damage_dealt_by_monster: int
var player_alive_at_end: int
var monster_alive_at_end: int
var player_hp_at_end: int
var monster_hp_at_end: int


func _init(
	turn_number_: int,
	attacks_played_: int,
	crit_count_: int,
	damage_dealt_by_player_: int,
	damage_dealt_by_monster_: int,
	player_alive_at_end_: int,
	monster_alive_at_end_: int,
	player_hp_at_end_: int,
	monster_hp_at_end_: int,
) -> void:
	turn_number = turn_number_
	attacks_played = attacks_played_
	crit_count = crit_count_
	damage_dealt_by_player = damage_dealt_by_player_
	damage_dealt_by_monster = damage_dealt_by_monster_
	player_alive_at_end = player_alive_at_end_
	monster_alive_at_end = monster_alive_at_end_
	player_hp_at_end = player_hp_at_end_
	monster_hp_at_end = monster_hp_at_end_
