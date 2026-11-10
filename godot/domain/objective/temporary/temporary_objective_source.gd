@abstract
class_name TemporaryObjectiveSource
extends RefCounted
## lib/domain/objective/temporary/temporary_objective_source.dart: one event
## able to set a temporary objective: when it is active, read from the saved
## EventState, and how it ends, read from what the events did while a turn
## ended.


## The objective active during `turn`, or null.
@abstract func active_in(state: EventState, turn: int) -> TemporaryObjective


## The objective that ended at the end of the turn of `outcome`, or null.
@abstract func ended_by(outcome: EventTurnOutcome) -> TemporaryObjectiveEnd
