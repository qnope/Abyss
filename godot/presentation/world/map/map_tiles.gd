class_name MapTiles
extends MultiMeshInstance3D
## The floor of the map: one tile per cell, all in one MultiMesh (a single draw
## call for the whole level), each in the colour and at the height
## [WorldModels.terrain] gives for its terrain and whether it is seen: a cell
## not seen is dark and lower, as under a cover of fog. Every other tile seen
## is a little lighter so that the grid reads.

## The share of a cell a tile covers: the rest is the seam between two.
const FILL := 0.94


## The colour and the height of the top of each tile, in the order of the grid
## (the MultiMesh keeps them in the video memory, out of reach of a test).
var colours := PackedColorArray()
var tops := PackedFloat32Array()


func _init() -> void:
	name = &"Tiles"
	var tile := BoxMesh.new()
	tile.size = Vector3(FILL * MapGrid.CELL, MapGrid.DEPTH, FILL * MapGrid.CELL)
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = true
	multimesh.mesh = tile
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.9
	material_override = material


## Lays the floor of [param looks] (the cells of a map [param width] by
## [param height], in the order of the grid).
func show_looks(looks: Array[MapLook], width: int, height: int) -> void:
	multimesh.instance_count = looks.size()
	colours.resize(looks.size())
	tops.resize(looks.size())
	for index in looks.size():
		var look := looks[index]
		var floor_ := WorldModels.terrain(look.terrain, look.revealed)
		var centre := MapGrid.at(look.x, look.y, width, height)
		centre.y = floor_.height - MapGrid.DEPTH / 2.0
		multimesh.set_instance_transform(index, Transform3D(Basis.IDENTITY, centre))
		tops[index] = floor_.height
		colours[index] = floor_.colour.lightened(MapPalette.CHECKER) \
			if look.revealed and (look.x + look.y) % 2 == 1 else floor_.colour
		multimesh.set_instance_color(index, colours[index])
