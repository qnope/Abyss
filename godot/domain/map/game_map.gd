class_name GameMap
extends RefCounted
## lib/domain/map/game_map.dart: the grid of one level, its cells row by
## row: the cell (x, y) is `cells[y * width + x]`.

var width: int
var height: int
var cells: Array[MapCell]
## Dart's `seed`, which is a function of Godot: the seed the map was
## generated from.
var map_seed: int


func _init(width_: int, height_: int, cells_: Array[MapCell], seed_: int) -> void:
	width = width_
	height = height_
	cells = cells_
	map_seed = seed_


func cell_at(x: int, y: int) -> MapCell:
	return cells[y * width + x]


func set_cell(x: int, y: int, cell: MapCell) -> void:
	cells[y * width + x] = cell
