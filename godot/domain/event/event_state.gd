class_name EventState
extends RefCounted
## lib/domain/event/event_state.dart: per-player bookkeeping of the random
## events: when the next one is drawn, the one waiting for a choice and the
## effect that lasts. A turn is an int or null, an event a
## RandomEventType.Value or null.

## End of the turn of the next draw, null when none is scheduled yet.
var next_draw_turn: Variant
## Drawn event waiting for the player's choice, or null.
var pending: Variant
## Turn during which the player chooses for `pending`.
var pending_turn: Variant
## Last drawn event, never drawn twice in a row.
var last_drawn: Variant
## Event whose effect lasts (currents, storm), or null.
var active: Variant
## Last turn, inclusive, of the `active` effect.
var active_until_turn: Variant
## Whether the player heats the farms during a cold current.
var heating: bool
## Events drawn since the start of the game.
var events_seen: int
## Survivors met by the pending survivors event (an int or null), who join
## as harpoonists if welcomed.
var survivors: Variant
## Resource the pending caravan takes (a ResourceType.Value or null), the
## most abundant at its draw.
var trade_from: Variant
## Resource the pending caravan gives, the scarcest at its draw.
var trade_to: Variant
## Wave of the predators drawn, kept until they are fought or baited.
var predator_wave: MonsterLair
## Turn at the end of which the faced `predator_wave` strikes the base.
var predators_turn: Variant
## Cell of level 1 where a wreck lies, until searched or sunk.
var wreck_position: GridPosition
## Last turn, inclusive, the wreck can be searched. Kept until the end of
## the turn of its search (see wreck_searched).
var wreck_until_turn: Variant


func _init(
	next_draw_turn_: Variant = null,
	pending_: Variant = null,
	pending_turn_: Variant = null,
	last_drawn_: Variant = null,
	active_: Variant = null,
	active_until_turn_: Variant = null,
	heating_ := false,
	events_seen_ := 0,
	survivors_: Variant = null,
	trade_from_: Variant = null,
	trade_to_: Variant = null,
	predator_wave_: MonsterLair = null,
	predators_turn_: Variant = null,
	wreck_position_: GridPosition = null,
	wreck_until_turn_: Variant = null,
) -> void:
	next_draw_turn = next_draw_turn_
	pending = pending_
	pending_turn = pending_turn_
	last_drawn = last_drawn_
	active = active_
	active_until_turn = active_until_turn_
	heating = heating_
	events_seen = events_seen_
	survivors = survivors_
	trade_from = trade_from_
	trade_to = trade_to_
	predator_wave = predator_wave_
	predators_turn = predators_turn_
	wreck_position = wreck_position_
	wreck_until_turn = wreck_until_turn_


func has_pending() -> bool:
	return pending != null and pending_turn != null


## Whether the wreck was searched during the turn being played: it left the
## map but its `wreck_until_turn` waits for the end of the turn.
func wreck_searched() -> bool:
	return wreck_position == null and wreck_until_turn != null


## Whether the effect of `type` applies during `turn`.
func is_active(type: RandomEventType.Value, turn: int) -> bool:
	if active == null or active_until_turn == null:
		return false
	var until: int = active_until_turn
	return active == type and turn <= until


func schedule(turn: int) -> void:
	next_draw_turn = turn


## Records the draw of `type`, never drawn twice in a row.
func record_draw(type: RandomEventType.Value) -> void:
	last_drawn = type
	events_seen += 1


## Records the draw of `type`, waiting for a choice during `turn`.
func set_pending(type: RandomEventType.Value, turn: int) -> void:
	record_draw(type)
	pending = type
	pending_turn = turn


## Settles the pending event, forgetting its offer.
func clear_pending() -> void:
	pending = null
	pending_turn = null
	survivors = null
	trade_from = null
	trade_to = null


## Forgets the predators, fought or baited away.
func clear_predators() -> void:
	predator_wave = null
	predators_turn = null


## Forgets the wreck, searched or sunk, once the turn is over.
func clear_wreck() -> void:
	wreck_position = null
	wreck_until_turn = null


## Starts the lasting effect of `type`, through `until_turn` inclusive.
func activate(type: RandomEventType.Value, until_turn: int) -> void:
	active = type
	active_until_turn = until_turn
	heating = false


## Ends the lasting effect once `turn` is past its last turn.
func expire_effects(turn: int) -> void:
	if active_until_turn == null:
		return
	var until: int = active_until_turn
	if turn <= until:
		return
	active = null
	active_until_turn = null
	heating = false
