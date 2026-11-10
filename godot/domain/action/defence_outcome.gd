class_name DefenceOutcome
extends RefCounted
## lib/domain/action/attack_base_defence.dart, `DefenceOutcome`: what a base
## fielded against an attack, and what became of it.

## The units that defended, by type.
var engaged: Dictionary[UnitType.Value, int]
var survivors_intact: Dictionary[UnitType.Value, int]
var wounded: Dictionary[UnitType.Value, int]
var dead: Dictionary[UnitType.Value, int]
## The defenders as they entered the fight, rampart included.
var initial: Array[Combatant]


func _init(
	engaged_: Dictionary[UnitType.Value, int],
	survivors_intact_: Dictionary[UnitType.Value, int],
	wounded_: Dictionary[UnitType.Value, int],
	dead_: Dictionary[UnitType.Value, int],
	initial_: Array[Combatant],
) -> void:
	engaged = engaged_
	survivors_intact = survivors_intact_
	wounded = wounded_
	dead = dead_
	initial = initial_
