class_name PredatorsObjectiveSource
extends TemporaryObjectiveSource
## lib/domain/objective/temporary/sources/predators_objective_source.dart:
## repel the school of predators once the player chose to face them, through
## the turn at whose end they strike: done if the fight is won, failed if
## lost. Baited predators set no objective.


func active_in(state: EventState, turn: int) -> TemporaryObjective:
	var due: Variant = state.predators_turn
	if state.predator_wave == null or due == null or turn > due:
		return null
	var last_turn: int = due
	return _objective(last_turn)


func ended_by(outcome: EventTurnOutcome) -> TemporaryObjectiveEnd:
	var fight := outcome.predators
	if fight == null:
		return null
	var ending := TemporaryObjectiveOutcome.Value.DONE if fight.victory else TemporaryObjectiveOutcome.Value.FAILED
	return TemporaryObjectiveEnd.new(_objective(fight.turn), ending)


static func _objective(due: int) -> TemporaryObjective:
	return TemporaryObjective.new(TemporaryObjectiveKind.Value.PREDATORS, due)
