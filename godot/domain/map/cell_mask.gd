class_name CellMask
extends RefCounted
## lib/domain/map/cell_mask.dart: flat boolean grid over a `width` x
## `height` map: which cells are marked.
##
## Built once from a list of positions so that, on a hot path, membership
## and neighbourhood tests cost an index computation and allocate nothing.

var width: int
var height: int
## One byte per cell, 1 when marked.
var _cells: PackedByteArray


## Marks every position of `marked` that lies on the grid.
func _init(width_: int, height_: int, marked: Array[GridPosition]) -> void:
	width = width_
	height = height_
	_cells = PackedByteArray()
	_cells.resize(width * height)
	for p: GridPosition in marked:
		if _on_grid(p.x, p.y):
			_cells[p.y * width + p.x] = 1


## Whether (`x`, `y`) is marked; a cell off the grid never is.
func contains(x: int, y: int) -> bool:
	return _on_grid(x, y) and _cells[y * width + x] == 1


## Whether (`x`, `y`) or one of its eight neighbours is marked.
func touches(x: int, y: int) -> bool:
	for dy: int in range(-1, 2):
		for dx: int in range(-1, 2):
			if contains(x + dx, y + dy):
				return true
	return false


func _on_grid(x: int, y: int) -> bool:
	return x >= 0 and x < width and y >= 0 and y < height
