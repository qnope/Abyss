class_name MapWriter
extends RefCounted
## Writes a generated map as a vector case does: its size, its bases and
## every cell that holds anything. tool/vectors/domain/map_writer.dart on
## the Godot side.


## The whole of `result`. "cells" lists, in the order of the grid, the cells
## that are not bare (see `cell`) as `[index, ...cell]`, `index` being
## `y * width + x`; the cells left out are bare.
static func write(result: MapGenerationResult) -> Dictionary:
	var cells := []
	for index: int in result.map.cells.size():
		var written := cell(result.map.cells[index])
		if written.size() > 1 or written[0] != "empty":
			cells.append([index] + written)
	return {
		"seed": result.map.map_seed,
		"width": result.map.width,
		"height": result.map.height,
		"baseX": result.base_x,
		"baseY": result.base_y,
		"bases": result.bases.map(func(b: GridPosition) -> Array: return [b.x, b.y]),
		"cells": cells,
	}


## Every field of the cell: its content, its lair as `[difficulty, family,
## unitCount]`, its transition base as `[type, name]` and its passage name,
## the trailing nulls left out. A cell keeps the lair or the base it was
## given when its content changes afterwards, so a lair can lie under any
## content. A bare cell is `["empty"]`. A cell that holds what no generated
## cell does logs an error, where Dart throws.
static func cell(held: MapCell) -> Array:
	var lair := held.lair
	var base := held.transition_base
	if (
		held.terrain != TerrainType.Value.PLAIN
		or held.collected_by != null
		or (lair != null and (lair.second_family != null or lair.second_count != 0))
		or (base != null and base.is_captured())
	):
		push_error("MapWriter: a generated cell holds more than a vector writes.")
	var written := [DartEnum.name_of(CellContentType.Value, held.content), null, null, null]
	if lair != null:
		written[1] = [
			DartEnum.name_of(MonsterDifficulty.Value, lair.difficulty),
			VectorInputs.name_or_null(MonsterFamily.Value, lair.family),
			lair.unit_count,
		]
	if base != null:
		written[2] = [DartEnum.name_of(TransitionBaseType.Value, base.type), base.name]
	written[3] = held.passage_name
	while written.back() == null:
		written.pop_back()
	return written
