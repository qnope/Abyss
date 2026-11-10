class_name PostHolder
extends RefCounted
## lib/domain/map/post_holder.dart: who holds a Faille or a Cheminée, as the
## human sees it: its guardians until someone takes it, then the human or a
## rival faction.

enum Value { GUARDIANS, HUMAN, FACTION }


## Who holds `base`, seen by the player `human_id`.
static func of(base: TransitionBase, human_id: String) -> Value:
	if base.captured_by == null:
		return Value.GUARDIANS
	return Value.HUMAN if base.captured_by == human_id else Value.FACTION


## Who holds each base of the level `above` (null without one), by the key
## of its position: the level below holds its passage at the same place.
static func passages_below(above: GameMap, human_id: String) -> Dictionary[Vector2i, Value]:
	var holders: Dictionary[Vector2i, Value] = {}
	if above == null:
		return holders
	for position: Vector2i in PassageExtractor.from(above):
		holders[position] = of(above.cell_at(position.x, position.y).transition_base, human_id)
	return holders
