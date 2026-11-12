extends SceneTree
## Renders a creature (a model with a rig and its actions) for review: three
## poses of each of its actions, and how it reads at phone size. The board's
## strips come from it (board.sh), and tool/models/poses.sh runs it:
##   godot --path godot --script res://tool/models/poses.gd -- <name> <out prefix>
## writes <out prefix>_<action>_<k>.png (k from 0) for each action the model
## has, and <out prefix>_phone.png: the figure as the game's default camera
## frames it on the parade ground (a ground 10 m wide on the phone's screen,
## cut round the figure). A model with no animation renders only the latter.

const Studio := preload("res://tool/models/studio.gd")
const ModelBounds := preload("res://tool/models/model_bounds.gd")
const ModelFacing := preload("res://tool/models/model_facing.gd")

## Where in each action its poses are taken, as shares of its length: the
## wind-up, the blow and the recovery of an action that plays once, the
## extremes of a loop.
const SHARES := {
	&"idle": [0.0, 0.25, 0.75], &"swim": [0.25, 0.5, 0.75],
	&"attack": [0.22, 0.45, 0.7], &"hit": [0.25, 0.5, 0.8],
}
const POSE_SIZE := Vector2i(448, 448)
## The figure, turned to show its front a quarter off a camera at +z.
const POSE_YAW := 135.0
const POSE_PITCH := -14.0
const POSE_FOV := 30.0
## The phone's portrait frame at 2x, the game's camera, and the ground it frames.
const PHONE := Vector2i(780, 1688)
const PHONE_FOV := 38.0
const PHONE_PITCH := -50.0
const PHONE_GROUND := 10.4
const PHONE_CROP := 176

var _viewport := SubViewport.new()
var _camera := Camera3D.new()
var _model: Node3D
var _bounds: AABB


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var scene: PackedScene = null if args.size() != 2 else load("res://assets/models/%s.glb" % args[0])
	if scene == null:
		printerr("usage: poses.gd -- <model name> <out prefix>")
		quit(2)
		return
	_model = scene.instantiate() as Node3D
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_viewport.msaa_3d = Viewport.MSAA_4X
	_viewport.use_hdr_2d = true
	_viewport.positional_shadow_atlas_size = 4096
	root.add_child(_viewport)
	_bounds = ModelBounds.of(_model)
	_viewport.add_child(Studio.new(_model, _bounds))
	_camera.keep_aspect = Camera3D.KEEP_WIDTH
	_viewport.add_child(_camera)
	await _render_all(args[1])
	quit(0)


func _render_all(prefix: String) -> void:
	var players := _model.find_children("*", "AnimationPlayer", true, false)
	if not players.is_empty():
		await _poses(players[0] as AnimationPlayer, prefix)
	await _phone(prefix + "_phone.png")


func _poses(player: AnimationPlayer, prefix: String) -> void:
	ModelFacing.face(_model, POSE_YAW)
	# The camera stays where it is for every pose, wide enough for a lunge.
	var radius := ModelBounds.of(_model, true).size.length() * 0.58
	_view(POSE_SIZE, 0.0, POSE_PITCH, POSE_FOV, Vector3(0.0, _bounds.get_center().y, 0.0),
		radius / sin(deg_to_rad(POSE_FOV) * 0.5))
	for action: StringName in SHARES:
		if not player.has_animation(action):
			continue
		var shares: Array = SHARES[action]
		for k in 3:
			var share: float = shares[k]
			player.play(action)
			player.pause()
			player.seek(player.get_animation(action).length * share, true)
			await _save("%s_%s_%d.png" % [prefix, action, k])
	player.stop()


func _phone(path: String) -> void:
	ModelFacing.face(_model, ModelFacing.GAME)
	var reach := PHONE_GROUND / 2.0 / tan(deg_to_rad(PHONE_FOV) / 2.0)
	_view(PHONE, 45.0, PHONE_PITCH, PHONE_FOV, Vector3.ZERO, reach)
	await _save(path, Rect2i((PHONE - Vector2i.ONE * PHONE_CROP) / 2, Vector2i.ONE * PHONE_CROP))


## Puts the camera [param distance] from [param target], looking at it from
## the angles given, and sizes the viewport.
func _view(size: Vector2i, yaw: float, pitch: float, fov: float, target: Vector3, distance: float) -> void:
	_viewport.size = size
	_camera.fov = fov
	var direction := Basis.from_euler(Vector3(deg_to_rad(pitch), deg_to_rad(yaw), 0.0)) * Vector3.BACK
	_camera.near = 0.05
	_camera.far = distance * 4.0
	_camera.look_at_from_position(target + direction * distance, target)


func _save(path: String, region := Rect2i()) -> void:
	for i in 4:
		await RenderingServer.frame_post_draw
	var image := _viewport.get_texture().get_image()
	if region.has_area():
		image = image.get_region(region)
	if image.save_png(path) != OK:
		printerr("cannot write %s" % path)
	else:
		print(path)
