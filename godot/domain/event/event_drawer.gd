class_name EventDrawer
extends RefCounted
## lib/domain/event/event_drawer.dart: decides when the next random event is
## drawn and which one.


## End of the turn of the first draw, when none is scheduled yet. A new game
## draws between FIRST_DRAW_MIN and FIRST_DRAW_MAX; a save made before the
## events draws a gap after `ended_turn`.
static func first_draw_turn(ended_turn: int, random: DartRandom) -> int:
	if ended_turn >= EventRules.FIRST_DRAW_MIN:
		return next_draw_turn(ended_turn, random)
	const SPAN := EventRules.FIRST_DRAW_MAX - EventRules.FIRST_DRAW_MIN + 1
	return EventRules.FIRST_DRAW_MIN + random.next_int(SPAN)


## End of the turn of the draw after the one of `draw_turn`.
static func next_draw_turn(draw_turn: int, random: DartRandom) -> int:
	const SPAN := EventRules.MAX_GAP - EventRules.MIN_GAP + 1
	return draw_turn + EventRules.MIN_GAP + random.next_int(SPAN)


## Draws uniformly among the events allowed at the end of `ended_turn` (a
## RandomEventType.Value), or returns null without rolling when none is.
## Never `last_drawn` (an event or null), never one of `excluded`, and no
## predators for a turn before PREDATORS_FIRST_TURN.
static func pick(
	random: DartRandom,
	ended_turn: int,
	last_drawn: Variant,
	excluded: Dictionary[RandomEventType.Value, bool],
) -> Variant:
	var too_early := ended_turn + 1 < EventRules.PREDATORS_FIRST_TURN
	var candidates: Array[RandomEventType.Value] = []
	for type: RandomEventType.Value in RandomEventType.Value.values():
		if (
			type != last_drawn
			and not excluded.has(type)
			and not (too_early and type == RandomEventType.Value.PREDATORS)
		):
			candidates.append(type)
	if candidates.is_empty():
		return null
	return candidates[random.next_int(candidates.size())]
