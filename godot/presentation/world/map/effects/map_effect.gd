class_name MapEffect
extends Node3D
## Something the map plays once over its cells (lib/presentation/widgets/map/
## effects/map_effect.dart): a strike on a lair, a siege, the fog lifting. A new
## kind is a subclass that sets its [method duration] and shows itself at a
## time [method _show]; [MapEffects] plays it, [method advance] moving the time
## on by the seconds it is given, so a test drives it frame by frame.
##
## [method finish] ends it at once, its last moment shown, which is how a player
## skips it: every effect leaves the map as it was drawn without it.

## The effect is over: [method finish] ran.
signal finished

## Seconds played so far.
var elapsed := 0.0
## Whether it is over.
var is_done := false


## How long the effect plays, in seconds.
func duration() -> float:
	return 0.0


## How far the camera is shaken to the side now, in metres.
func jolt() -> float:
	return 0.0


## Plays [param seconds] more of it; the last moment ends it.
func advance(seconds: float) -> void:
	if is_done:
		return
	elapsed = minf(elapsed + seconds, duration())
	if elapsed >= duration():
		finish()
	else:
		_show(elapsed)


## Ends the effect at once: its last moment is shown, then [signal finished]
## is told. It never ends twice.
func finish() -> void:
	if is_done:
		return
	is_done = true
	elapsed = duration()
	_show(elapsed)
	finished.emit()


## Shows the effect [param t] seconds into it.
func _show(_t: float) -> void:
	pass
