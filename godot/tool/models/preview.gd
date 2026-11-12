extends SceneTree
## Renders a model of assets/models/, as the game imports it, in a neutral
## studio: from the game's 3/4 camera and from four sides, at twice the
## phone's scale. tool/models/preview.sh runs it:
##   godot --path godot --script res://tool/models/preview.gd -- <name> <out prefix>
## writes <out prefix>_game.png, _close.png (the front quarter, zoomed in),
## _front.png, _right.png, _back.png, _left.png. Names joined by "+"
## (base_island+base_rampart) render those models together, each building on
## the island's pad named after it. A third argument, a tier number, shows the
## model up to that tier (model_tiers.gd) and renders only its game and close
## views: the board's rows of a building's tiers.

const Studio := preload("res://tool/models/studio.gd")
const ModelBounds := preload("res://tool/models/model_bounds.gd")
const ModelPads := preload("res://tool/models/model_pads.gd")
const ModelTiers := preload("res://tool/models/model_tiers.gd")

## The phone's viewport (project.godot), rendered at 2x.
const SCALE := 2
const PHONE := Vector2i(390, 844)
const SIDE := Vector2i(512, 512)

## The game's default camera: from the front corner of the base (largest u
## and v), looking down at it, its horizontal field framing the plateau.
const GAME_YAW := 45.0
const GAME_PITCH := -50.0
const GAME_FOV := 38.0
const SIDE_PITCH := -18.0
const SIDE_FOV := 30.0

var _viewport: SubViewport
var _camera: Camera3D


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2 or args.size() > 3:
		printerr("usage: preview.gd -- <model name> <out prefix> [tier]")
		quit(2)
		return
	var model := _load(args[0])
	if model == null:
		quit(1)
		return
	var tier := int(args[2]) if args.size() == 3 else 0
	if tier > 0:
		ModelTiers.show_up_to(model, tier)
	_render(model, args[1], tier > 0)


func _load(names: String) -> Node3D:
	var group := Node3D.new()
	for name in names.split("+"):
		var path := "res://assets/models/%s.glb" % name
		var scene := load(path) as PackedScene
		if scene == null:
			printerr("cannot load %s" % path)
			group.free()
			return null
		group.add_child(scene.instantiate())
	ModelPads.seat(group)
	return group


func _render(model: Node3D, prefix: String, tiered: bool) -> void:
	_viewport = SubViewport.new()
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_viewport.msaa_3d = Viewport.MSAA_4X
	# Glow needs an HDR buffer in the Compatibility renderer: in an 8-bit one
	# the whole background blooms.
	_viewport.use_hdr_2d = true
	_viewport.positional_shadow_atlas_size = 4096
	root.add_child(_viewport)
	var bounds := ModelBounds.of(model)
	_viewport.add_child(Studio.new(model, bounds))
	_camera = Camera3D.new()
	_camera.keep_aspect = Camera3D.KEEP_WIDTH
	_viewport.add_child(_camera)
	var shots: Array[Shot] = [
		Shot.new("game", PHONE, GAME_YAW, GAME_PITCH, GAME_FOV, true),
		Shot.new("close", SIDE, GAME_YAW, GAME_PITCH, GAME_FOV / 2.5, true),
		Shot.new("front", SIDE, 0.0, SIDE_PITCH, SIDE_FOV, false),
		Shot.new("right", SIDE, 90.0, SIDE_PITCH, SIDE_FOV, false),
		Shot.new("back", SIDE, 180.0, SIDE_PITCH, SIDE_FOV, false),
		Shot.new("left", SIDE, 270.0, SIDE_PITCH, SIDE_FOV, false),
	]
	for shot in shots:
		if tiered and not shot.game:
			continue
		await _shoot(bounds, shot, "%s_%s.png" % [prefix, shot.name])
	quit(0)


func _shoot(bounds: AABB, shot: Shot, path: String) -> void:
	_viewport.size = shot.size * SCALE
	_camera.fov = shot.fov
	var target := Vector3.ZERO if shot.game else bounds.get_center()
	var radius := ModelBounds.top_radius(bounds) if shot.game else bounds.size.length() * 0.5
	if shot.fov < GAME_FOV and shot.game:
		# A close-up of the front quarter, as the player zooms in.
		target = Vector3(1.0, 0.0, 1.0) * radius * 0.35
		radius /= 2.5
	var direction := Basis.from_euler(Vector3(deg_to_rad(shot.pitch), deg_to_rad(shot.yaw), 0.0)) \
		* Vector3.BACK
	var distance := radius / sin(deg_to_rad(shot.fov) * 0.5) * (1.08 if shot.game else 1.0)
	_camera.near = maxf(distance - radius * 4.0, 0.05)
	_camera.far = distance + radius * 4.0
	_camera.look_at_from_position(target + direction * distance, target)
	for i in 4:
		await RenderingServer.frame_post_draw
	var image := _viewport.get_texture().get_image()
	var error := image.save_png(path)
	if error != OK:
		printerr("cannot write %s: %s" % [path, error_string(error)])
	else:
		print(path)


## A view of the model: its name, size in phone points, angles in degrees,
## horizontal field of view, and whether it frames the plateau as the game.
class Shot:
	var name: String
	var size: Vector2i
	var yaw: float
	var pitch: float
	var fov: float
	var game: bool

	func _init(name_: String, size_: Vector2i, yaw_: float, pitch_: float, fov_: float, \
			game_: bool) -> void:
		name = name_
		size = size_
		yaw = yaw_
		pitch = pitch_
		fov = fov_
		game = game_
