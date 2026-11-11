class_name MapContents
extends Node3D
## What stands on the map's cells: for each look with a content, whatever
## [WorldModels.map_content] gives (a model or a stand-in), on the top of its
## tile. The volcano, which covers 2 x 2 cells, stands on the middle of them.

## What stands on each cell, by its key.
var by_cell: Dictionary[Vector2i, Node3D] = {}


## Stands the contents of [param looks] (the cells of a map [param width] by
## [param height]) in place of the ones standing before.
func show_looks(looks: Array[MapLook], width: int, height: int) -> void:
	for child: Node in get_children():
		# Freed in the tree: a node with its own materials, freed outside it,
		# makes the renderer complain.
		child.free()
	by_cell.clear()
	for look in looks:
		if look.content == null:
			continue
		var kind: MapContent.Kind = look.content
		var content := WorldModels.map_content(kind, look.tint, look.dimmed)
		var floor_ := WorldModels.terrain(look.terrain, look.revealed)
		content.name = "Cell%d_%d" % [look.x, look.y]
		content.position = MapGrid.at(look.x, look.y, width, height) \
			+ Vector3(1.0, 0.0, 1.0) * (look.span - 1) * MapGrid.CELL / 2.0 \
			+ Vector3.UP * floor_.height
		by_cell[look.key()] = content
		add_child(content)
