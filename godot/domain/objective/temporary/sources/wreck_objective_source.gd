class_name WreckObjectiveSource
extends TemporaryObjectiveSource
## lib/domain/objective/temporary/sources/wreck_objective_source.dart: search
## the wreck by its last turn, while it lies on the map: done once searched,
## expired once sunk.


func active_in(state: EventState, turn: int) -> TemporaryObjective:
	var until: Variant = state.wreck_until_turn
	if state.wreck_position == null or until == null or turn > until:
		return null
	var last_turn: int = until
	return _objective(last_turn)


func ended_by(outcome: EventTurnOutcome) -> TemporaryObjectiveEnd:
	var wreck := outcome.wreck
	if wreck == null:
		return null
	var ending := TemporaryObjectiveOutcome.Value.DONE if wreck.searched else TemporaryObjectiveOutcome.Value.EXPIRED
	return TemporaryObjectiveEnd.new(_objective(wreck.until_turn), ending)


static func _objective(until: int) -> TemporaryObjective:
	return TemporaryObjective.new(TemporaryObjectiveKind.Value.WRECK, until)
