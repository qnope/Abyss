class_name TemporaryObjectiveEnd
extends RefCounted
## lib/domain/objective/temporary/temporary_objective_end.dart: a temporary
## objective that ended at the end of a turn. Its enum is
## temporary_objective_outcome.gd.

var objective: TemporaryObjective
var outcome: TemporaryObjectiveOutcome.Value


func _init(objective_: TemporaryObjective, outcome_: TemporaryObjectiveOutcome.Value) -> void:
	objective = objective_
	outcome = outcome_


func is_done() -> bool:
	return outcome == TemporaryObjectiveOutcome.Value.DONE
