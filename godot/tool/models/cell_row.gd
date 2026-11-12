extends Node3D
## Models side by side on the cells of a map, floor and camera as the game's,
## to judge their relative scale and how they tell apart: the review board's
## row of what stands on the cells (tool/models/cells.sh). Each model stands
## on the floor under the centre of its cell (a model of span 2, the volcano,
## on the middle of its 2 x 2), and may be tinted or dimmed as the game does.

## The cells a content covers per side, by model name: the volcano covers 2 x 2.
const SPANS := {"map_kernel": 2}
## How much of its colour a tinted node glows with.
const TINT_GLOW := 0.5

## The cell of each model, in the order given.
var cells: Array[Vector2i] = []
## The size of the grid, in cells.
var size := Vector2i.ZERO


## Lays [param models] (Node3D) out in rows of at most [param per_row] cells.
func _init(models: Array[Node3D], spans: Array[int], per_row: int) -> void:
	cells = layout(spans, per_row)
	for cell in cells.size():
		size = size.max(cells[cell] + Vector2i.ONE * spans[cell])
	var looks: Array[MapLook] = []
	for y in size.y:
		for x in size.x:
			looks.append(MapLook.new(x, y, TerrainType.Value.PLAIN, true))
	var tiles := MapTiles.new()
	tiles.show_looks(looks, size.x, size.y)
	add_child(tiles)
	for index in models.size():
		var model := models[index]
		model.position = MapGrid.at(cells[index].x, cells[index].y, size.x, size.y) \
			+ Vector3(1.0, 0.0, 1.0) * (spans[index] - 1) * MapGrid.CELL / 2.0
		add_child(model)


## The top left cell of each content of [param spans] (cells per side), laid
## out in rows of at most [param per_row] cells; a row is as high as its
## widest content.
static func layout(spans: Array[int], per_row: int) -> Array[Vector2i]:
	var placed: Array[Vector2i] = []
	var x := 0
	var y := 0
	var row := 1
	for span in spans:
		if x > 0 and x + span > per_row:
			x = 0
			y += row
			row = 1
		placed.append(Vector2i(x, y))
		x += span
		row = maxi(row, span)
	return placed


## Gives the node [param model] has named Tint the colour [param colour], as
## the game recolours a holder's banner: a material of its own, lit by it.
static func tint(model: Node3D, colour: Color) -> bool:
	var node := model.get_node_or_null("Tint") as MeshInstance3D
	if node == null:
		return false
	var material := StandardMaterial3D.new()
	material.albedo_color = colour * 0.5
	material.emission_enabled = true
	material.emission = colour
	material.emission_energy_multiplier = TINT_GLOW
	node.material_override = material
	return true


## The models named in [param names] ("map_faille", or "map_faille@69f0ae" to
## tint it, "map_wreck!" to dim it), from assets/models/, null for one that
## does not load.
static func load_models(names: PackedStringArray) -> Array[Node3D]:
	var models: Array[Node3D] = []
	for entry in names:
		var dimmed := entry.ends_with("!")
		var parts := entry.trim_suffix("!").split("@")
		var path := "res://assets/models/%s.glb" % parts[0]
		var scene := load(path) as PackedScene if ResourceLoader.exists(path) else null
		if scene == null:
			for model in models:
				model.free()
			return []
		var model := scene.instantiate() as Node3D
		if parts.size() > 1:
			tint(model, Color(parts[1]))
		if dimmed:
			veil(model)
		models.append(model)
	return models


## Puts [param camera] on the default view of this grid as the game fits it,
## but without the game's nearest zoom (a few cells would not fill a screen).
func frame(camera: MapCamera, aspect: float) -> void:
	var rig := camera.pan
	var fitted := OrbitFrame.fit(MapGrid.outline(size.x, size.y), rig.yaw, rig.pitch, aspect,
		OrbitCamera.FOV, 0.0)
	camera.keep_aspect = Camera3D.KEEP_WIDTH if aspect < 1.0 else Camera3D.KEEP_HEIGHT
	rig.distance = fitted.x
	rig.goal_distance = fitted.x
	rig.lift = fitted.y
	camera.transform = rig.transform()


## The cells a content of the model [param name] covers per side.
static func span_of(name: String) -> int:
	return SPANS.get(name.trim_suffix("!").split("@")[0], 1)


## Dulls every mesh of [param model] under the game's veil of degraded grey
## (WorldModels does so for a content already emptied).
static func veil(model: Node3D) -> void:
	var overlay := StandardMaterial3D.new()
	overlay.albedo_color = Color(WorldPalette.DEGRADED, WorldModels.VEIL)
	overlay.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for node: Node in model.find_children("*", "GeometryInstance3D", true, false):
		(node as GeometryInstance3D).material_overlay = overlay
