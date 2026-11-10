class_name IdleFrameCap
extends Node
## Caps the frame rate once the player has left the view still for a
## moment: a turn-based game mostly waits, and a phone drawing 30 frames a
## second instead of 60 spends half the energy. The ambience goes on moving,
## at 30. A touch or a move of the view lifts the cap on the next frame.
## Engine.max_fps is the process's: the cap gives it back when it leaves.

const IDLE_FPS := 30
## How long the view must stand still, in seconds.
const IDLE_DELAY := 2.0

## Whether the cap may apply.
var enabled := true:
	set = set_enabled

var _camera: OrbitCamera
var _still := 0.0


func _init(camera: OrbitCamera) -> void:
	_camera = camera


func _process(delta: float) -> void:
	if not enabled:
		return
	if _camera.is_moving():
		_still = 0.0
		Engine.max_fps = 0
	else:
		_still += delta
		if _still >= IDLE_DELAY:
			Engine.max_fps = IDLE_FPS


func _exit_tree() -> void:
	Engine.max_fps = 0


func set_enabled(on: bool) -> void:
	enabled = on
	_still = 0.0
	Engine.max_fps = 0


## Whether the frame rate is capped now.
func is_capped() -> bool:
	return Engine.max_fps == IDLE_FPS
