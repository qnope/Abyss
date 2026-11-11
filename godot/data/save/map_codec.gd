class_name MapCodec
extends RefCounted
## The maps of a save, their cells and what the cells hold, and the
## positions every other codec writes.


static func position(x: GridPosition) -> Dictionary:
	return {"x": x.x, "y": x.y}


static func read_position(r: SaveReader, value: Variant) -> GridPosition:
	var m := r.object(value, "GridPosition")
	return GridPosition.new(r.int_at(m, "x"), r.int_at(m, "y"))


static func read_position_or_null(r: SaveReader, value: Variant) -> GridPosition:
	return null if value == null else read_position(r, value)


static func lair(x: MonsterLair) -> Dictionary:
	return {
		"difficulty": SaveValues.name(MonsterDifficulty.Value, x.difficulty), "unitCount": x.unit_count,
		"family": SaveValues.name_or_null(MonsterFamily.Value, x.family),
		"secondFamily": SaveValues.name_or_null(MonsterFamily.Value, x.second_family), "secondCount": x.second_count,
	}


static func read_lair(r: SaveReader, value: Variant) -> MonsterLair:
	var m := r.object(value, "MonsterLair")
	return MonsterLair.new(
		r.enum_at(m, "difficulty", MonsterDifficulty.Value), r.int_at(m, "unitCount"),
		r.enum_or_null_at(m, "family", MonsterFamily.Value), r.enum_or_null_at(m, "secondFamily", MonsterFamily.Value),
		r.int_at(m, "secondCount"),
	)


static func read_lair_or_null(r: SaveReader, value: Variant) -> MonsterLair:
	return null if value == null else read_lair(r, value)


static func transition_base(x: TransitionBase) -> Dictionary:
	return {"type": SaveValues.name(TransitionBaseType.Value, x.type), "name": x.name, "capturedBy": x.captured_by}


static func read_transition_base(r: SaveReader, value: Variant) -> TransitionBase:
	var m := r.object(value, "TransitionBase")
	return TransitionBase.new(
		r.enum_at(m, "type", TransitionBaseType.Value), r.text_at(m, "name"), r.text_or_null_at(m, "capturedBy"),
	)


static func cell(x: MapCell) -> Dictionary:
	return {
		"terrain": SaveValues.name(TerrainType.Value, x.terrain),
		"content": SaveValues.name(CellContentType.Value, x.content),
		"lair": SaveValues.or_null(x.lair, lair), "collectedBy": x.collected_by,
		"transitionBase": SaveValues.or_null(x.transition_base, transition_base), "passageName": x.passage_name,
	}


static func read_cell(r: SaveReader, value: Variant) -> MapCell:
	var m := r.object(value, "MapCell")
	var base: Variant = r.object_or_null_at(m, "transitionBase")
	return MapCell.new(
		r.enum_at(m, "terrain", TerrainType.Value), r.enum_at(m, "content", CellContentType.Value),
		read_lair_or_null(r, r.at(m, "lair")), r.text_or_null_at(m, "collectedBy"),
		null if base == null else read_transition_base(r, base), r.text_or_null_at(m, "passageName"),
	)


## The cells in row order: the cell at (x, y) is `y * width + x`.
static func game_map(x: GameMap) -> Dictionary:
	return {"width": x.width, "height": x.height, "cells": SaveValues.list_of(x.cells, cell), "seed": x.map_seed}


static func read_game_map(r: SaveReader, value: Variant) -> GameMap:
	var m := r.object(value, "GameMap")
	var cells: Array[MapCell] = []
	cells.assign(SaveCollections.list_of(r, r.at(m, "cells"), "cells", read_cell))
	return GameMap.new(r.int_at(m, "width"), r.int_at(m, "height"), cells, r.int_at(m, "seed"))
