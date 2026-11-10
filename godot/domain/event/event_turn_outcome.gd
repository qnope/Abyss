class_name EventTurnOutcome
extends RefCounted
## lib/domain/event/event_turn_outcome.dart: what the random events did
## while a turn ended.

## Event drawn this turn (a RandomEventType.Value), or null; one with a
## choice waits for it during the next turn.
var drawn: Variant
## Event left without a choice, settled with its prudent option, or null.
var defaulted: Variant
## School of predators faced this turn, fought at its end.
var predators: RaidReport
## Wreck searched during this turn, or sunk at its end, if any.
var wreck: WreckEnding


func _init(
	drawn_: Variant = null, defaulted_: Variant = null, predators_: RaidReport = null,
	wreck_: WreckEnding = null,
) -> void:
	drawn = drawn_
	defaulted = defaulted_
	predators = predators_
	wreck = wreck_
