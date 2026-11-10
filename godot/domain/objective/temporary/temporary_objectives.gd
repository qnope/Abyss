class_name TemporaryObjectives
extends RefCounted
## lib/domain/objective/temporary/temporary_objectives.dart: the temporary
## objectives the events set, derived from the event state of a player:
## nothing of theirs is saved.


## Every event able to set one, in display order; a new event adds its own
## TemporaryObjectiveSource here. A const list in Dart: new sources at each
## call.
static func sources() -> Array[TemporaryObjectiveSource]:
	return [WreckObjectiveSource.new(), PredatorsObjectiveSource.new()]


## The objectives of `player` active during the current turn of `game`.
static func active_of(game: Game, player: Player) -> Array[TemporaryObjective]:
	var active: Array[TemporaryObjective] = []
	for source: TemporaryObjectiveSource in sources():
		var objective := source.active_in(player.event_state, game.turn)
		if objective != null:
			active.append(objective)
	return active


## The objectives that ended while a turn ended, from what the events did
## then.
static func ended_by(outcome: EventTurnOutcome) -> Array[TemporaryObjectiveEnd]:
	var ended: Array[TemporaryObjectiveEnd] = []
	for source: TemporaryObjectiveSource in sources():
		var end := source.ended_by(outcome)
		if end != null:
			ended.append(end)
	return ended
