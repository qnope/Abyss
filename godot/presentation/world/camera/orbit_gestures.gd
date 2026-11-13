class_name OrbitGestures
extends RefCounted
## Turns the player's input into moves of an OrbitRig: one finger or the
## mouse's left button drags the view around, two fingers pinch it, the
## wheel and a trackpad's pinch or scroll zoom it. A finger turns the view
## only once it left the tap's slop, and a pinch only zooms until every finger
## lifts: neither the first finger, down before the second, nor the last one,
## lifted after the other, turns it. A touch or a click that barely moved is a
## tap, for the scene to pick what lies under it.

## A tap on this point of the screen, in the viewport's coordinates.
signal tapped(position: Vector2)

## How far a touch may move, in points, and still be a tap.
const TAP_SLOP := 10.0
## The zoom of one notch of the wheel, and of a trackpad's scroll by a point.
const WHEEL_STEP := 1.12
const PAN_ZOOM := 0.01
## The mouse's left button, held as a touch of its own.
const MOUSE := -1

var _rig: OrbitRig
## Where each finger (or the mouse, as MOUSE) touches, by index.
var _touches: Dictionary[int, Vector2] = {}
var _pressed_at := Vector2.ZERO
var _last_move := 0.0
## Whether the current touch moved too far, or pinched, to be a tap.
var _moved := false
## Whether a second finger came down since the first: the touch then zooms.
var _pinched := false


func _init(rig: OrbitRig) -> void:
	_rig = rig


## Moves the rig after [param event], received [param now] (seconds), and
## tells whether it used it.
func handle(event: InputEvent, now: float) -> bool:
	if event is InputEventMouse and event.device == InputEvent.DEVICE_ID_EMULATION:
		return false
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		_touch(touch.index, touch.position, touch.pressed, touch.canceled, now)
		return true
	if event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		return _move(drag.index, drag.position, drag.relative, now)
	if event is InputEventMouseButton:
		return _click(event as InputEventMouseButton, now)
	if event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		return _move(MOUSE, motion.position, motion.relative, now)
	if event is InputEventMagnifyGesture:
		_rig.zoom(1.0 / (event as InputEventMagnifyGesture).factor)
		return true
	if event is InputEventPanGesture:
		_rig.zoom(maxf(1.0 + (event as InputEventPanGesture).delta.y * PAN_ZOOM, 0.1))
		return true
	return false


## Whether a finger or the mouse's button is down.
func is_touching() -> bool:
	return not _touches.is_empty()


func _click(event: InputEventMouseButton, now: float) -> bool:
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			_touch(MOUSE, event.position, event.pressed, false, now)
			return true
		MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN:
			var notches := event.factor if event.factor > 0.0 else 1.0
			var step := pow(WHEEL_STEP, notches)
			_rig.zoom(1.0 / step if event.button_index == MOUSE_BUTTON_WHEEL_UP else step)
			return true
	return false


func _touch(index: int, position: Vector2, pressed: bool, canceled: bool, now: float) -> void:
	if pressed:
		_touches[index] = position
		_last_move = now
		if _touches.size() == 1:
			_pressed_at = position
			_moved = false
			_pinched = false
		else:
			_moved = true
			_pinched = true
			_rig.hold()
		return
	_touches.erase(index)
	_last_move = now
	if _touches.is_empty():
		_rig.release()
		if not _moved and not canceled:
			tapped.emit(position)


func _move(index: int, position: Vector2, relative: Vector2, now: float) -> bool:
	if not _touches.has(index):
		return false
	if _touches.size() == 1:
		_moved = _moved or position.distance_to(_pressed_at) > TAP_SLOP
		if _moved and not _pinched:
			_rig.drag(relative, now - _last_move)
	else:
		var before := _span()
		_touches[index] = position
		var after := _span()
		if before > 0.0 and after > 0.0:
			_rig.zoom(before / after)
	_touches[index] = position
	_last_move = now
	return true


## The distance between the first two fingers down.
func _span() -> float:
	var points: Array[Vector2] = _touches.values()
	return points[0].distance_to(points[1])
