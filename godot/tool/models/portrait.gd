extends SceneTree
## Renders the portraits of models of assets/models/, as the game imports
## them, for the interface: a fixed 3/4 camera (portrait_camera.gd), the
## studio's light, a transparent background, 256 px square (twice the 128
## points of the largest portrait). tool/models/portraits.sh runs it:
##   godot --path godot --script res://tool/models/portrait.gd -- <out dir> <name>...
## writes <out dir>/<name>.png for each name.

const Studio := preload("res://tool/models/studio.gd")
const ModelBounds := preload("res://tool/models/model_bounds.gd")
const PortraitCamera := preload("res://tool/models/portrait_camera.gd")
const ModelFacing := preload("res://tool/models/model_facing.gd")

## The side of a portrait in pixels.
const SIDE := 256


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		printerr("usage: portrait.gd -- <out dir> <model name>...")
		quit(2)
		return
	_render_all(args[0], args.slice(1))


func _render_all(folder: String, names: PackedStringArray) -> void:
	var status := 0
	for name in names:
		if not await _render(name, folder.path_join(name + ".png")):
			status = 1
	quit(status)


func _render(name: String, path: String) -> bool:
	var scene := load("res://assets/models/%s.glb" % name) as PackedScene
	if scene == null:
		printerr("cannot load the model %s" % name)
		return false
	var model := scene.instantiate() as Node3D
	var viewport := SubViewport.new()
	viewport.size = Vector2i(SIDE, SIDE)
	viewport.transparent_bg = true
	viewport.msaa_3d = Viewport.MSAA_4X
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.positional_shadow_atlas_size = 2048
	root.add_child(viewport)
	# A creature faces the camera; the box that fits the picture is the turned one.
	ModelFacing.face(model, ModelFacing.GAME)
	var bounds := ModelBounds.of(model, ModelFacing.is_creature(model))
	viewport.add_child(Studio.new(model, bounds, true))
	var camera := Camera3D.new()
	viewport.add_child(camera)
	PortraitCamera.frame(camera, bounds)
	for i in 4:
		await RenderingServer.frame_post_draw
	var error := viewport.get_texture().get_image().save_png(path)
	viewport.queue_free()
	if error != OK:
		printerr("cannot write %s: %s" % [path, error_string(error)])
		return false
	print(path)
	return true
