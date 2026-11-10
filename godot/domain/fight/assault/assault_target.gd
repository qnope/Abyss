class_name AssaultTarget
extends RefCounted
## lib/domain/fight/assault/assault_target.dart: what an assault led by an
## Abyss Admiral can capture. Its `passage` waits for the action module
## (PostTakeover).

enum Value { FAILLE, CHEMINEE, KERNEL }


## `target.guardians()`: the guardians the assault fights, fresh at each
## call.
static func guardians(target: Value) -> Array[Combatant]:
	match target:
		Value.FAILLE: return GuardianFactory.for_type(TransitionBaseType.Value.FAILLE)
		Value.CHEMINEE: return GuardianFactory.for_type(TransitionBaseType.Value.CHEMINEE)
	# kernel, the last target.
	return GuardianFactory.for_volcanic_kernel()


## Not in the Dart class: the tear-off `target.guardians`, a Callable giving
## fresh guardians at each call, as a planner takes its enemy.
static func guardians_of(target: Value) -> Callable:
	return guardians.bind(target)


## The target still to capture at (`x`, `y`) on `level` of `game`, any cell
## of the volcano meaning the kernel; null when there is none (a Value or
## null).
static func at(game: Game, level: int, x: int, y: int) -> Variant:
	var map: GameMap = game.levels.get(level)
	if map == null:
		return null
	var anchor := VolcanoFootprint.anchor_of(map, x, y)
	if anchor != null:
		return null if map.cell_at(anchor.x, anchor.y).is_collected() else Value.KERNEL
	var cell := map.cell_at(x, y)
	var base := cell.transition_base
	if cell.content != CellContentType.Value.TRANSITION_BASE or base == null:
		return null
	if base.is_captured():
		return null
	return Value.FAILLE if base.type == TransitionBaseType.Value.FAILLE else Value.CHEMINEE
