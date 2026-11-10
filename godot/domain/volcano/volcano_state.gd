class_name VolcanoState
extends RefCounted
## lib/domain/volcano/volcano_state.dart: per-player bookkeeping of the
## waves that try to take the kernel back.

## Announced wave, or null when none is coming.
var incoming: MonsterLair
## Turn at the end of which `incoming` hits the kernel (an int), or null.
var arrival_turn: Variant
## Waves the garrison pushed back since the start of the game.
var waves_repelled: int
## Kernel levels the waves took since the start of the game.
var levels_lost: int


func _init(
	incoming_: MonsterLair = null,
	arrival_turn_: Variant = null,
	waves_repelled_ := 0,
	levels_lost_ := 0,
) -> void:
	incoming = incoming_
	arrival_turn = arrival_turn_
	waves_repelled = waves_repelled_
	levels_lost = levels_lost_


## Waves fought on the kernel since the start of the game, won or lost.
## Zero until the first one, which is drawn at half strength.
func waves_fought() -> int:
	return waves_repelled + levels_lost


func is_incoming() -> bool:
	return incoming != null and arrival_turn != null


func announce(wave: MonsterLair, turn: int) -> void:
	incoming = wave
	arrival_turn = turn


func clear_incoming() -> void:
	incoming = null
	arrival_turn = null


## Records the outcome of a wave fought on the kernel.
func record_outcome(victory: bool) -> void:
	if victory:
		waves_repelled += 1
	else:
		levels_lost += 1
