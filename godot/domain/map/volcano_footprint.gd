class_name VolcanoFootprint
extends RefCounted
## lib/domain/map/volcano_footprint.dart: reads and repairs the 2x2 volcano.
## The anchor (top-left, the `VOLCANIC_KERNEL`) carries the state, the other
## cells are parts.
##
## `migrate`, which runs complete_legacy() on every level of a Hive save
## being loaded, is not ported: the Godot saves are not those.

const _KERNEL := CellContentType.Value.VOLCANIC_KERNEL
const _PART := CellContentType.Value.VOLCANIC_KERNEL_PART


## What a tap on a cell means, the record `tapTarget` returns in Dart.
class TapTarget:
	extends RefCounted
	## The cell to act on: the anchor for any cell of the volcano.
	var position: GridPosition
	## Whether the player has seen it.
	var is_revealed: bool

	func _init(position_: GridPosition, is_revealed_: bool) -> void:
		position = position_
		is_revealed = is_revealed_


## The anchor of the volcano covering (`x`, `y`), or null if that cell is
## not part of a volcano.
static func anchor_of(map: GameMap, x: int, y: int) -> GridPosition:
	var content := map.cell_at(x, y).content
	if content == _KERNEL:
		return GridPosition.new(x, y)
	if content != _PART:
		return null
	for dy: int in VolcanicKernelPlacer.SIDE:
		for dx: int in VolcanicKernelPlacer.SIDE:
			var ax := x - dx
			var ay := y - dy
			if ax < 0 or ay < 0:
				continue
			if map.cell_at(ax, ay).content == _KERNEL:
				return GridPosition.new(ax, ay)
	return null


## What a tap on (`x`, `y`) means: the cell to act on (the anchor for any
## cell of the volcano) and whether the player has seen it, the volcano
## counting as seen as soon as one of its cells is. `revealed` is the set of
## the cells seen, by the key of their position.
static func tap_target(
	map: GameMap, revealed: Dictionary[Vector2i, bool], x: int, y: int
) -> TapTarget:
	var anchor := anchor_of(map, x, y)
	if anchor == null:
		return TapTarget.new(GridPosition.new(x, y), revealed.has(Vector2i(x, y)))
	var seen := false
	for cell: Vector2i in VolcanicKernelPlacer.footprint(anchor.x, anchor.y):
		seen = seen or revealed.has(cell)
	return TapTarget.new(anchor, seen)


## Reveals the whole volcano to `player` on `level` once one of its cells
## is seen, as the map shows it.
static func reveal_whole(map: GameMap, player: Player, level: int) -> void:
	var seen := player.revealed_cells_set_on_level(level)
	if seen.is_empty():
		return
	for y: int in map.height:
		for x: int in map.width:
			if map.cell_at(x, y).content != _KERNEL:
				continue
			var cells := VolcanicKernelPlacer.footprint(x, y)
			if not cells.any(func(cell: Vector2i) -> bool: return seen.has(cell)):
				continue
			for cell: Vector2i in cells:
				player.add_revealed_cell(level, GridPosition.of_key(cell))


## Gives a volcano saved as a single cell its three parts.
static func complete_legacy(map: GameMap) -> void:
	for y: int in map.height:
		for x: int in map.width:
			if map.cell_at(x, y).content != _KERNEL:
				continue
			for part: Vector2i in VolcanicKernelPlacer.footprint(x, y).slice(1):
				if part.x >= map.width or part.y >= map.height:
					continue
				var held := map.cell_at(part.x, part.y).content
				if held == CellContentType.Value.PASSAGE or held == CellContentType.Value.WRECK:
					continue
				map.set_cell(part.x, part.y, map.cell_at(part.x, part.y).copy_with(
					{"content": _PART, "lair": null, "transition_base": null}
				))
