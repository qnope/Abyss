class_name NextFrame
extends RefCounted
## Waits for the frame after the one being processed, for work that must not
## weigh on the frame in which an action shows (the save of [GameSession]).
##
## The scene tree handles a touch, then tells `process_frame`, then draws:
## the first `process_frame` after a touch belongs to the frame of the touch,
## not drawn yet. So the wait ends on the first one told in a later frame, by
## the engine's count of frames. A test gives frames and a count of its own
## and makes them pass itself (`tests/manual_frames.gd`).

## The frame after the one [method wait] was called in has begun.
signal came

const NONE := -1

var _frames: Signal
var _count: Callable
## The frame the wait was asked in, [constant NONE] when nothing waits.
var _asked_in := NONE


## Waits on [param frames], told once a frame at least, whose number
## [param count] gives (a Callable returning an int): the scene tree's
## `process_frame` and the engine's count unless told otherwise.
func _init(frames: Signal = (Engine.get_main_loop() as SceneTree).process_frame,
		count: Callable = Engine.get_process_frames) -> void:
	_frames = frames
	_count = count


## Asks for [signal came] on the next frame, once however many times it is
## asked before then.
func wait() -> void:
	if not is_waiting():
		_asked_in = _count.call()
		_frames.connect(_on_frame)


## Waits no more: [signal came] is not told.
func cancel() -> void:
	if is_waiting():
		_asked_in = NONE
		_frames.disconnect(_on_frame)


func is_waiting() -> bool:
	return _asked_in != NONE


func _on_frame() -> void:
	var frame: int = _count.call()
	if frame != _asked_in:
		cancel()
		came.emit()
