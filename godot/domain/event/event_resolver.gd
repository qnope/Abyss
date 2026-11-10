class_name EventResolver
extends RefCounted
## lib/domain/event/event_resolver.dart: end-of-turn step of the random
## events, after the production and the raid: upkeeps the lasting effect,
## fights the predators faced this turn, settles the event left without a
## choice, ends the lasting effects and what the events left on the map
## (the wreck searched or sunk), then draws the next event when due.


## `random` null is Dart's own die, `Random()`.
static func resolve(game: Game, player: Player, ended_turn: int, random: DartRandom = null) -> EventTurnOutcome:
	var dice := random if random != null else DartRandom.unseeded()
	_upkeep(game, player, ended_turn)
	var predators := PredatorsEffect.strike(player, ended_turn, dice)
	var defaulted: Variant = _settle(game, player, ended_turn, dice)
	player.event_state.expire_effects(ended_turn + 1)
	EventEffects.end_turn(game, player, ended_turn)
	var wreck := WreckEffect.settle(game, player, ended_turn)
	return EventTurnOutcome.new(_draw(game, player, ended_turn, dice), defaulted, predators, wreck)


## Upkeep of the effect lasting through `ended_turn`.
static func _upkeep(game: Game, player: Player, ended_turn: int) -> void:
	if player.event_state.active == null:
		return
	var active: RandomEventType.Value = player.event_state.active
	if not player.event_state.is_active(active, ended_turn):
		return
	EventEffects.of(active).on_turn_end(game, player, ended_turn)


## Applies the prudent option of an event whose turn of choice is over,
## from the next turn on; returns it (a RandomEventType.Value) or null.
static func _settle(game: Game, player: Player, ended_turn: int, dice: DartRandom) -> Variant:
	var state := player.event_state
	if not state.has_pending() or state.pending_turn > ended_turn:
		return null
	var type: RandomEventType.Value = state.pending
	EventEffects.apply(game, player, type, false, ended_turn + 1, dice)
	state.clear_pending()
	player.add_history_entry(EventEntry.new(ended_turn, type, false, true))
	return type


## The event drawn at the end of `ended_turn` (a RandomEventType.Value), or
## null.
static func _draw(game: Game, player: Player, ended_turn: int, dice: DartRandom) -> Variant:
	var state := player.event_state
	var due: Variant = state.next_draw_turn
	if due == null:
		state.schedule(EventDrawer.first_draw_turn(ended_turn, dice))
		return null
	if ended_turn < due:
		return null
	if state.has_pending() or state.active != null:
		state.schedule(ended_turn + 1)
		return null
	var type: Variant = EventDrawer.pick(
		dice, ended_turn, state.last_drawn, EventEffects.excluded_at(game, player, ended_turn)
	)
	if type != null:
		var picked: RandomEventType.Value = type
		_start(game, player, picked, ended_turn, dice)
	state.schedule(EventDrawer.next_draw_turn(ended_turn, dice))
	return type


## Announces `type`, or plays it out at once when it has no choice.
static func _start(game: Game, player: Player, type: RandomEventType.Value, ended_turn: int, dice: DartRandom) -> void:
	EventEffects.on_draw(game, player, type, ended_turn, dice)
	if RandomEventChoice.has_choice(type):
		player.event_state.set_pending(type, ended_turn + 1)
		return
	player.event_state.record_draw(type)
	EventEffects.apply(game, player, type, true, ended_turn + 1, dice)
	player.add_history_entry(EventEntry.new(ended_turn, type, true, false))
