extends SceneTree
## Renders the game's startup scene for review, as a phone held upright
## shows it, from a few views of the base. tool/scene_capture.sh runs it:
##   godot --path godot --resolution 780x1688 --script res://tool/scene/capture.gd -- <out dir> [scene]
## writes <out dir>/default.png (the game's view), rotated.png, close.png
## (zoomed on the headquarters) and top.png (from above, the quality panel
## open), the scene having run a few hundred frames first.

const SCENE := "res://app/main.tscn"
## Frames to let the scene run before a shot: particles fill the water.
const WARM_UP := 240
const SETTLE := 30

var _scene: Node


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		printerr("usage: capture.gd -- <out dir> [scene]")
		quit(2)
		return
	var scene := load(args[1] if args.size() > 1 else SCENE) as PackedScene
	_scene = scene.instantiate()
	root.add_child(_scene)
	_capture(args[0])


func _capture(folder: String) -> void:
	DirAccess.make_dir_recursive_absolute(folder)
	var camera := _scene.find_children("*", "OrbitCamera", true, false)[0] as OrbitCamera
	await _frames(WARM_UP)
	var shots: Array[Shot] = [
		Shot.new("default", OrbitRig.DEFAULT_YAW, OrbitRig.DEFAULT_PITCH, camera.rig.default_distance),
		Shot.new("rotated", OrbitRig.DEFAULT_YAW + 110.0, -38.0, 26.0),
		Shot.new("close", OrbitRig.DEFAULT_YAW + 20.0, -30.0, OrbitRig.MIN_DISTANCE,
			Vector3(0.4, 1.2, 0.4)),
		Shot.new("top", OrbitRig.DEFAULT_YAW, OrbitRig.MIN_PITCH, camera.rig.default_distance),
	]
	for shot in shots:
		camera.rig.target = shot.target
		camera.rig.look(shot.yaw, shot.pitch, shot.distance)
		if shot.name == "top":
			_open_panels()
		await _frames(SETTLE)
		var path := folder.path_join("%s.png" % shot.name)
		root.get_texture().get_image().save_png(path)
		print(path)
		for line in _report():
			print("  ", line)
	quit(0)


func _open_panels() -> void:
	for panel in _scene.find_children("*", "Control", true, false):
		if panel.has_method(&"expand"):
			panel.call(&"expand")


func _report() -> PackedStringArray:
	return PackedStringArray([
		"draw calls %d, primitives %d, objects %d" % [
			Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
			Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
			Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),
		],
	])


func _frames(count: int) -> void:
	for i in count:
		await process_frame


## A view of the base: its file's name, the orbit's angles in degrees, its
## distance and the point it looks at.
class Shot:
	var name: String
	var yaw: float
	var pitch: float
	var distance: float
	var target: Vector3

	func _init(name_: String, yaw_: float, pitch_: float, distance_: float, \
			target_ := Vector3.ZERO) -> void:
		name = name_
		yaw = yaw_
		pitch = pitch_
		distance = distance_
		target = target_
