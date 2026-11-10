class_name LostRaid
extends RefCounted
## lib/domain/game/defeat_analysis.dart, `LostRaid`: one of the raids that
## made the base fall.

var turn: int
var wave: MonsterLair
## Units that stood on the base, all types together.
var defenders: int


func _init(turn_: int, wave_: MonsterLair, defenders_: int) -> void:
	turn = turn_
	wave = wave_
	defenders = defenders_
