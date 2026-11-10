class_name OrbitCamera
extends Camera3D
## The camera of the base: it orbits after the player's gestures, through
## OrbitGestures, on the view of its OrbitRig, eased and flung frame by
## frame, and tells a tap so that the scene picks what lies under it.

## A tap on this point of the screen, in the viewport's coordinates.
signal tapped(position: Vector2)

## The horizontal field of view, which frames the plateau on a phone held
## upright (keep_aspect = KEEP_WIDTH).
const FOV := 38.0

## The view, which a bench or a cutscene may also drive.
var rig := OrbitRig.new()
var _gestures := OrbitGestures.new(rig)


func _init() -> void:
	fov = FOV
	keep_aspect = KEEP_WIDTH
	near = 0.5
	far = 160.0
	transform = rig.transform()
	_gestures.tapped.connect(tapped.emit)


func _unhandled_input(event: InputEvent) -> void:
	if _gestures.handle(event, Time.get_ticks_usec() / 1e6):
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	rig.step(delta)
	transform = rig.transform()


## Whether the player touches the screen or the view still moves.
func is_moving() -> bool:
	return _gestures.is_touching() or not rig.is_settled()
