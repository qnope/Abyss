class_name EventStateTexts
extends RefCounted
## lib/presentation/extensions/event_state_extensions.dart (EventStateDisplay
## and its two functions): the countdowns of the random events of a player,
## in the language on.


## Turns left, the current [param turn] included, of something lasting through
## [param until_turn] inclusive.
static func turns_left(until_turn: int, turn: int) -> int:
	return until_turn - turn + 1


## `countdownText`: "Tempête : encore 2 tours".
static func countdown_text(label: String, turns: int) -> String:
	return Texts.t(&"eventCountdown", {"label": label, "turns": turns})


## "Épave : encore N tours" when the wreck lies at ([param x], [param y]) on
## [param level] during [param turn], null otherwise.
static func wreck_countdown_at(state: EventState, x: int, y: int, level: int, turn: int) -> Variant:
	var at := state.wreck_position
	if at == null or state.wreck_until_turn == null or level != WreckSites.LEVEL:
		return null
	if at.x != x or at.y != y:
		return null
	return wreck_countdown(state, turn)


## "Épave : encore N tours" while a wreck lies on the map, else null.
static func wreck_countdown(state: EventState, turn: int) -> Variant:
	if state.wreck_position == null or state.wreck_until_turn == null:
		return null
	var until: int = state.wreck_until_turn
	var label := RandomEventTexts.label(RandomEventType.Value.WRECK)
	return countdown_text(label, turns_left(until, turn))


## The countdown of the effect lasting during [param turn], e.g. "Tempête :
## encore 2 tours", null when none applies.
static func effect_countdown(state: EventState, turn: int) -> Variant:
	if state.active == null or state.active_until_turn == null:
		return null
	var type: RandomEventType.Value = state.active
	var until: int = state.active_until_turn
	if not state.is_active(type, turn):
		return null
	var name := RandomEventTexts.label(type)
	if type == RandomEventType.Value.COLD_CURRENT and state.heating:
		name = Texts.t(&"eventColdCurrentHeated", {"label": name})
	return countdown_text(name, turns_left(until, turn))
