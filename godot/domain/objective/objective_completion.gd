class_name ObjectiveCompletion
extends RefCounted
## lib/domain/objective/objective_completion.dart: an objective completed at
## the end of a turn, and what its reward actually added once capped by the
## storage.

var objective: Objective
## Resources added, by type; less than the reward of the objective when the
## storage was nearly full.
var credited: Dictionary[ResourceType.Value, int]


func _init(objective_: Objective, credited_: Dictionary[ResourceType.Value, int]) -> void:
	objective = objective_
	credited = credited_
