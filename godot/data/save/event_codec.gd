class_name EventCodec
extends RefCounted
## The random events of a player, in a save: the next draw, the event that
## waits for a choice, the one that lasts, and what some of them left.

const Event := RandomEventType.Value


static func event_state(x: EventState) -> Dictionary:
	return {
		"nextDrawTurn": x.next_draw_turn, "pending": SaveValues.name_or_null(Event, x.pending),
		"pendingTurn": x.pending_turn, "lastDrawn": SaveValues.name_or_null(Event, x.last_drawn),
		"active": SaveValues.name_or_null(Event, x.active), "activeUntilTurn": x.active_until_turn,
		"heating": x.heating, "eventsSeen": x.events_seen, "survivors": x.survivors,
		"tradeFrom": SaveValues.name_or_null(ResourceType.Value, x.trade_from),
		"tradeTo": SaveValues.name_or_null(ResourceType.Value, x.trade_to),
		"predatorWave": SaveValues.or_null(x.predator_wave, MapCodec.lair), "predatorsTurn": x.predators_turn,
		"wreckPosition": SaveValues.or_null(x.wreck_position, MapCodec.position), "wreckUntilTurn": x.wreck_until_turn,
	}


static func read_event_state(r: SaveReader, value: Variant) -> EventState:
	var m := r.object(value, "EventState")
	return EventState.new(
		r.int_or_null_at(m, "nextDrawTurn"), r.enum_or_null_at(m, "pending", Event), r.int_or_null_at(m, "pendingTurn"),
		r.enum_or_null_at(m, "lastDrawn", Event), r.enum_or_null_at(m, "active", Event),
		r.int_or_null_at(m, "activeUntilTurn"), r.bool_at(m, "heating"), r.int_at(m, "eventsSeen"),
		r.int_or_null_at(m, "survivors"), r.enum_or_null_at(m, "tradeFrom", ResourceType.Value),
		r.enum_or_null_at(m, "tradeTo", ResourceType.Value), MapCodec.read_lair_or_null(r, r.at(m, "predatorWave")),
		r.int_or_null_at(m, "predatorsTurn"), MapCodec.read_position_or_null(r, r.at(m, "wreckPosition")),
		r.int_or_null_at(m, "wreckUntilTurn"),
	)
