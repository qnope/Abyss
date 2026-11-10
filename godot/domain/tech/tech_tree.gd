class_name TechTree
extends RefCounted
## lib/domain/tech/tech_tree.dart: shape of every research branch. Odd
## levels are tiers shared by all players, even levels are a choice between
## two exclusive options.

const MAX_LEVEL := 5


## Levels holding a choice between two options (2 and 4).
static func is_choice_level(level: int) -> bool:
	return level > 0 and level < MAX_LEVEL and (level & 1) == 0


## Position of the choice node of `level` among a branch's choices.
static func choice_index(level: int) -> int:
	return DartMath.trunc_div(level, 2) - 1


## Tiers (levels 1, 3 and 5) completed once `research_level` is reached.
static func tiers_reached(research_level: int) -> int:
	return DartMath.trunc_div(research_level + 1, 2)
