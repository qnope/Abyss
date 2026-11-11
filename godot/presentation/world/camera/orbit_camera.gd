class_name OrbitCamera
extends Camera3D
## The camera of the base: it orbits after the player's gestures, through
## OrbitGestures, on the view of its OrbitRig, eased and flung frame by
## frame, and tells a tap so that the scene picks what lies under it.

## A tap on this point of the screen, in the viewport's coordinates.
signal tapped(position: Vector2)

## The field of view across the screen's narrow side: its width on a phone
## held upright, its height on a tablet or a desktop.
const FOV := 38.0

## The view, which a bench or a cutscene may also drive.
var rig := OrbitRig.new()
var _gestures := OrbitGestures.new(rig)


## [param rig_] is the view another camera drives (the map's pans where this
## one orbits); none makes the orbit's own.
func _init(rig_: OrbitRig = null) -> void:
	if rig_ != null:
		rig = rig_
		_gestures = OrbitGestures.new(rig)
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


## Fits the default view to the screen (OrbitFrame): [param outline], the
## points around the target that must show, as wide as the screen's narrow
## side allows, centred between the top [param hud] share of the screen and
## its bottom [param foot] share, seen from [param yaw] and [param pitch] (the
## orbit's default angles unless a camera has its own).
func fit(outline: PackedVector3Array, hud: float, foot := 0.0,
		yaw := OrbitRig.DEFAULT_YAW, pitch := OrbitRig.DEFAULT_PITCH) -> void:
	var size := get_viewport().get_visible_rect().size
	var aspect := size.x / size.y
	keep_aspect = KEEP_WIDTH if aspect < 1.0 else KEEP_HEIGHT
	var fitted := OrbitFrame.fit(outline, yaw, pitch, aspect, FOV, hud, foot)
	rig.frame(fitted.x, fitted.y)
	transform = rig.transform()


## Whether the player touches the screen or the view still moves.
func is_moving() -> bool:
	return _gestures.is_touching() or not rig.is_settled()
