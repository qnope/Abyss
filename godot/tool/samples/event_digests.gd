class_name EventDigests
extends RefCounted
## The short texts the digest test of the random events compares with what
## a scratch Dart script printed on the same games, and the choice it makes
## for the players as ChooseEventAction does. Each text writes what the
## Dart script writes, in its order.


## On three turns of four (`(turn + index) % 4 != 0`), settles the event
## waiting for `player`'s choice during `turn` as ChooseEventAction does:
## the predators always faced, any other accepted on even `turn + index`.
## Returns `turn Y|N type`, `turn ?type refusal` when the first option is
## refused, or "" without a choice.
static func choose(game: Game, player: Player, turn: int, index: int) -> String:
	var state := player.event_state
	if not state.has_pending() or state.pending_turn != turn or (turn + index) % 4 == 0:
		return ""
	var type: RandomEventType.Value = state.pending
	var name := DartEnum.name_of(RandomEventType.Value, type)
	var accept := type == RandomEventType.Value.PREDATORS or (turn + index) % 2 == 0
	var refusal: Variant = EventEffects.of(type).refusal(game, player) if accept else null
	if refusal != null:
		return "%d ?%s %s" % [turn, name, _name(ActionFailure.Value, refusal)]
	EventEffects.apply(game, player, type, accept, turn)
	state.clear_pending()
	player.add_history_entry(EventEntry.new(turn, type, accept, false))
	return "%d %s%s" % [turn, "Y" if accept else "N", name]


## What the draw left for the event just drawn: `@x,y` for a wreck, the
## wave of the predators, the survivors met, the caravan's `from>to`.
static func drawn(player: Player) -> String:
	var s := player.event_state
	match s.last_drawn:
		RandomEventType.Value.WRECK:
			return "@%d,%d" % [s.wreck_position.x, s.wreck_position.y]
		RandomEventType.Value.PREDATORS:
			return " " + RaidDigests.wave(s.predator_wave)
		RandomEventType.Value.SURVIVORS:
			return " %d" % s.survivors
		RandomEventType.Value.CARAVAN:
			return " %s>%s" % [_name(ResourceType.Value, s.trade_from), _name(ResourceType.Value, s.trade_to)]
	return ""


## `V|L wave dead wounded loot pillaged fight-turns`, the maps summed.
static func report(r: RaidReport) -> String:
	return "%s %s %d %d %d %d %d" % [
		"V" if r.victory else "L", RaidDigests.wave(r.wave), RaidDigests.sum(r.dead),
		RaidDigests.sum(r.wounded), RaidDigests.sum(r.loot), RaidDigests.sum(r.pillaged),
		r.fight.turn_count,
	]


## `nextDraw lastDrawn seen pending active until heating wreckX,wreckY
## wreckUntil | noise total repelled lost | stocks | units on the base`.
static func state(player: Player) -> String:
	var s := player.event_state
	var events := RandomEventType.Value
	var at := s.wreck_position
	var stocks := PackedStringArray()
	for stock: GameResource in player.resources.values():
		stocks.append(str(stock.amount))
	var units := PackedStringArray()
	for unit: Unit in player.units_on_level(1).values():
		units.append(str(unit.count))
	var r := player.raid_state
	return "%s %s %d %s %s %s %s %s,%s %s | %d %d %d %d | %s | %s" % [
		_text(s.next_draw_turn), _name(events, s.last_drawn), s.events_seen, _name(events, s.pending),
		_name(events, s.active), _text(s.active_until_turn), s.heating,
		_text(null if at == null else at.x), _text(null if at == null else at.y), _text(s.wreck_until_turn),
		r.noise, r.total_noise, r.raids_repelled, r.raids_lost, " ".join(stocks), " ".join(units),
	]


## The Dart name of the event `type`, a RandomEventType.Value.
static func name_of(type: Variant) -> String:
	return _name(RandomEventType.Value, type)


## The Dart name of `value` in `enumeration`, "null" for none.
static func _name(enumeration: Dictionary, value: Variant) -> String:
	if value == null:
		return "null"
	var known: int = value
	return DartEnum.name_of(enumeration, known)


static func _text(value: Variant) -> String:
	return "null" if value == null else str(value)
