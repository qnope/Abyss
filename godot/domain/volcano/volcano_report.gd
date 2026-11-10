class_name VolcanoReport
extends RefCounted
## lib/domain/volcano/volcano_report.dart: outcome of a kraken wave on the
## kernel, for the turn summary and the history.

var turn: int
var victory: bool
var wave: MonsterLair
var fight: FightResult
## Kernel level when the wave hit; it also sets the magma rampart.
var kernel_level: int
var defenders: Dictionary[UnitType.Value, int]
var survivors_intact: Dictionary[UnitType.Value, int]
var wounded: Dictionary[UnitType.Value, int]
var dead: Dictionary[UnitType.Value, int]


func _init(
	turn_: int,
	victory_: bool,
	wave_: MonsterLair,
	fight_: FightResult,
	kernel_level_: int,
	defenders_: Dictionary[UnitType.Value, int],
	survivors_intact_: Dictionary[UnitType.Value, int],
	wounded_: Dictionary[UnitType.Value, int],
	dead_: Dictionary[UnitType.Value, int],
) -> void:
	turn = turn_
	victory = victory_
	wave = wave_
	fight = fight_
	kernel_level = kernel_level_
	defenders = defenders_
	survivors_intact = survivors_intact_
	wounded = wounded_
	dead = dead_


## Kernel level once the wave is over: one less when it won (-1 from a
## level 0 kernel, as in Dart).
func kernel_level_after() -> int:
	return kernel_level if victory else kernel_level - 1
