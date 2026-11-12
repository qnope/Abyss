extends SceneTree
## Renders a level's floor laid on a grid of cells, as the game's map camera
## sees it, in the game's own light and water: the tiles of
## assets/models/map_terrain_<level>.glb in the variants the board gives them
## (grid_layout.gd), to judge their continuity and look.
##   godot --path godot --script res://tool/models/grid_view.gd -- <level> <out prefix>
## writes <out prefix>_grid.png (a board of cells all seen, a few contents on
## it) and <out prefix>_gridfog.png (the same with a patch seen and the rest
## under the fog) from a close view, and <out prefix>_far.png, a whole 20 x 20
## map in the phone's frame, as the game opens it.

const GridLayout := preload("res://tool/models/grid_layout.gd")
const GridFloor := preload("res://tool/models/grid_floor.gd")

const SCALE := 2
const PHONE := Vector2i(390, 844)
const BOARD := Vector2i(720, 460)
const SIDE := 10
const FAR_SIDE := 20
## Cells added round a board's frame, to show the backdrop beyond its rim.
const FRAME := 6
const FOV := 38.0
## What stands on the board, as cells from the lit patch's heart.
const CONTENTS: Dictionary[Vector2i, MapContent.Kind] = {
	Vector2i(0, 0): MapContent.Kind.HOME, Vector2i(2, -1): MapContent.Kind.TREASURE,
	Vector2i(-2, 1): MapContent.Kind.LAIR_EASY, Vector2i(1, 2): MapContent.Kind.RUINS,
	Vector2i(-1, -2): MapContent.Kind.LAIR_HARD, Vector2i(3, 1): MapContent.Kind.WRECK,
}

var _viewport: SubViewport
var _level: int
var _scene: Node3D


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2:
		printerr("usage: grid_view.gd -- <level> <out prefix>")
		quit(2)
		return
	_level = int(args[0])
	_render(args[1])


func _render(prefix: String) -> void:
	_viewport = SubViewport.new()
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_viewport.msaa_3d = Viewport.MSAA_4X
	_viewport.use_hdr_2d = true
	root.add_child(_viewport)
	_viewport.add_child(UnderwaterEnvironment.new())
	_viewport.add_child(KeyLight.new())
	var shots: Array[Shot] = [Shot.new("grid", SIDE, false, BOARD),
		Shot.new("gridfog", SIDE, true, BOARD), Shot.new("far", FAR_SIDE, true, PHONE)]
	for shot in shots:
		_scene = _board(shot.side, shot.fogged)
		_viewport.add_child(_scene)
		var camera := _camera(shot.side + (FRAME if shot.side == SIDE else 0), shot.size)
		_viewport.add_child(camera)
		_viewport.size = shot.size * SCALE
		for i in 4:
			await RenderingServer.frame_post_draw
		var path := "%s_%s.png" % [prefix, shot.name]
		if _viewport.get_texture().get_image().save_png(path) == OK:
			print(path)
		camera.free()
		_scene.free()
	quit(0)


## The board's cells: the lit tiles (or the fog's) and what stands on them.
func _board(side: int, fogged: bool) -> Node3D:
	var floor_ := GridFloor.build(_level, side, fogged)
	if side == SIDE:
		_content(floor_, side, fogged)
	return floor_


func _content(floor_: Node3D, side: int, fogged: bool) -> void:
	var heart := Vector2i(roundi(side * 0.4), roundi(side * 0.6)) if fogged else Vector2i(side / 2, side / 2)
	for offset: Vector2i in CONTENTS:
		var cell := heart + offset
		if fogged and not GridLayout.seen(cell.x, cell.y, side):
			continue
		var stand := WorldModels.map_content(CONTENTS[offset])
		stand.position = MapGrid.at(cell.x, cell.y, side, side)
		floor_.add_child(stand)


static func _camera(side: int, size: Vector2i) -> Camera3D:
	var camera := Camera3D.new()
	camera.fov = FOV
	var aspect := float(size.x) / size.y
	camera.keep_aspect = Camera3D.KEEP_WIDTH if aspect < 1.0 else Camera3D.KEEP_HEIGHT
	var rig := MapRig.new()
	var fitted := OrbitFrame.fit(MapGrid.outline(side, side), MapRig.YAW, MapRig.PITCH,
		aspect, FOV, 0.0)
	rig.frame(fitted.x, fitted.y)
	camera.transform = rig.transform()
	return camera


## A view of the board: its file's name, the cells across, whether part of it
## is under the fog, and the picture's size in phone points.
class Shot:
	var name: String
	var side: int
	var fogged: bool
	var size: Vector2i

	func _init(name_: String, side_: int, fogged_: bool, size_: Vector2i) -> void:
		name = name_
		side = side_
		fogged = fogged_
		size = size_
