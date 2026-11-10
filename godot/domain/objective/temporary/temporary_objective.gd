class_name TemporaryObjective
extends RefCounted
## lib/domain/objective/temporary/temporary_objective.dart: an objective an
## event sets for a while, outside the catalog and with no reward of its
## own: what the event gives is the reward. The presentation words it after
## its `kind` and `last_turn`.

var kind: TemporaryObjectiveKind.Value
## Last turn, inclusive, the objective can be reached.
var last_turn: int


func _init(kind_: TemporaryObjectiveKind.Value, last_turn_: int) -> void:
	kind = kind_
	last_turn = last_turn_


## `operator ==`: the same kind and last turn.
func equals(other: Variant) -> bool:
	if not other is TemporaryObjective:
		return false
	var objective: TemporaryObjective = other
	return objective.kind == kind and objective.last_turn == last_turn


## `hashCode`: the same for equal objectives, though not Dart's number.
func hash_code() -> int:
	return hash([kind, last_turn])


func _to_string() -> String:
	return "TemporaryObjective(%s, %d)" % [DartEnum.name_of(TemporaryObjectiveKind.Value, kind), last_turn]
