class_name MapLook
extends RefCounted
## How one cell of the map looks (lib/presentation/widgets/map/
## map_cell_visual.dart, `MapCellVisual`, without the sprites): its floor, whether
## it is seen, and what stands on it, if anything.

var x: int
var y: int
var terrain: TerrainType.Value
var revealed: bool
## What stands on the cell, a MapContent.Kind, or null.
var content: Variant = null
## The colour of the content when a holder, an owner or a faction tints it, a
## Color, or null.
var tint: Variant = null
## Whether the cell's content was emptied: shown dull.
var dimmed := false
## Cells the content covers per side: the volcano covers 2 x 2.
var span := 1
## Whether the content shows through the fog: a wreck must be seen to be
## explored.
var beacon := false


func _init(x_: int, y_: int, terrain_: TerrainType.Value, revealed_: bool) -> void:
	x = x_
	y = y_
	terrain = terrain_
	revealed = revealed_


## The cell's key.
func key() -> Vector2i:
	return Vector2i(x, y)
