class_name MapSnapshots
extends RefCounted
## lib/domain/reference/snapshots/map_snapshots.dart: snapshots of the maps
## and of what moves on them.


static func position() -> ClassSnapshot:
	return ClassSnapshot.new("GridPosition", {
		"x": func(p: GridPosition, _ids: PlayerIds) -> Variant: return p.x,
		"y": func(p: GridPosition, _ids: PlayerIds) -> Variant: return p.y,
	})


static func lair() -> ClassSnapshot:
	return ClassSnapshot.new("MonsterLair", {
		"difficulty": func(l: MonsterLair, _ids: PlayerIds) -> Variant:
			return SnapshotValues.name(MonsterDifficulty.Value, l.difficulty),
		"unitCount": func(l: MonsterLair, _ids: PlayerIds) -> Variant: return l.unit_count,
		"family": func(l: MonsterLair, _ids: PlayerIds) -> Variant:
			return SnapshotValues.name_or_null(MonsterFamily.Value, l.family),
		"secondFamily": func(l: MonsterLair, _ids: PlayerIds) -> Variant:
			return SnapshotValues.name_or_null(MonsterFamily.Value, l.second_family),
		"secondCount": func(l: MonsterLair, _ids: PlayerIds) -> Variant: return l.second_count,
	})


static func transition_base() -> ClassSnapshot:
	return ClassSnapshot.new("TransitionBase", {
		"type": func(b: TransitionBase, _ids: PlayerIds) -> Variant:
			return SnapshotValues.name(TransitionBaseType.Value, b.type),
		"name": func(b: TransitionBase, _ids: PlayerIds) -> Variant: return b.name,
		"capturedBy": func(b: TransitionBase, ids: PlayerIds) -> Variant: return ids.or_null(b.captured_by),
	})


static func cell() -> ClassSnapshot:
	var lairs := lair()
	var bases := transition_base()
	return ClassSnapshot.new("MapCell", {
		"terrain": func(c: MapCell, _ids: PlayerIds) -> Variant: return SnapshotValues.name(TerrainType.Value, c.terrain),
		"content": func(c: MapCell, _ids: PlayerIds) -> Variant:
			return SnapshotValues.name(CellContentType.Value, c.content),
		"lair": func(c: MapCell, ids: PlayerIds) -> Variant: return lairs.or_null(c.lair, ids),
		"collectedBy": func(c: MapCell, ids: PlayerIds) -> Variant: return ids.or_null(c.collected_by),
		"transitionBase": func(c: MapCell, ids: PlayerIds) -> Variant: return bases.or_null(c.transition_base, ids),
		"passageName": func(c: MapCell, _ids: PlayerIds) -> Variant: return c.passage_name,
	})


## The cells are in row order: the cell at (x, y) is `y * width + x`.
static func game_map() -> ClassSnapshot:
	var cells := cell()
	return ClassSnapshot.new("GameMap", {
		"width": func(m: GameMap, _ids: PlayerIds) -> Variant: return m.width,
		"height": func(m: GameMap, _ids: PlayerIds) -> Variant: return m.height,
		"cells": func(m: GameMap, ids: PlayerIds) -> Variant: return cells.list_of(m.cells, ids),
		"seed": func(m: GameMap, _ids: PlayerIds) -> Variant: return m.map_seed,
	})


static func exploration() -> ClassSnapshot:
	var positions := position()
	return ClassSnapshot.new("ExplorationOrder", {
		"target": func(o: ExplorationOrder, ids: PlayerIds) -> Variant: return positions.of(o.target, ids),
		"level": func(o: ExplorationOrder, _ids: PlayerIds) -> Variant: return o.level,
	})


static func reinforcement() -> ClassSnapshot:
	var positions := position()
	return ClassSnapshot.new("ReinforcementOrder", {
		"fromLevel": func(o: ReinforcementOrder, _ids: PlayerIds) -> Variant: return o.from_level,
		"toLevel": func(o: ReinforcementOrder, _ids: PlayerIds) -> Variant: return o.to_level,
		"units": func(o: ReinforcementOrder, _ids: PlayerIds) -> Variant: return SnapshotValues.counts(o.units, UnitType.Value),
		"departTurn": func(o: ReinforcementOrder, _ids: PlayerIds) -> Variant: return o.depart_turn,
		"arrivalPoint": func(o: ReinforcementOrder, ids: PlayerIds) -> Variant: return positions.of(o.arrival_point, ids),
	})
