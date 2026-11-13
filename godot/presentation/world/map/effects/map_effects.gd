class_name MapEffects
extends Node3D
## Plays the effects of the map, one at a time, for whoever acts on it
## (lib/presentation/widgets/map/effects/map_effects.dart): the map holds one,
## [method play] puts an effect on it and tells what to do [i]then[/i], once it
## is over. With the map out of sight (another tab is shown), or when the player
## asked for fewer animations, an effect is over at once, never staged: every
## effect leaves nothing behind. A new effect ends the one playing, and
## [method finish] ends it on request, which is how the turn story skips (`app/game/story/`).
##
## The effects are told the time here, frame by frame, and the shake of the
## camera they ask for is told by [signal jolted].

## The camera is shaken [param offset] metres to the side (0 when it rests).
signal jolted(offset: float)

## The effect playing, or null.
var current: MapEffect
## Fewer animations: every effect is over at once.
var reduced_motion := false


func _init() -> void:
	name = &"Effects"


func _ready() -> void:
	# A node with a `_process` is made to process as it enters the tree.
	set_process(is_playing())


## Whether an effect is playing.
func is_playing() -> bool:
	return current != null


## Plays [param effect], calling [param then] once it is over (at once if it is
## not staged), after ending the one playing.
func play(effect: MapEffect, then := Callable()) -> void:
	finish()
	if reduced_motion or not is_visible_in_tree():
		if then.is_valid():
			effect.finished.connect(then)
		effect.finish()
		effect.free()
		return
	current = effect
	effect.finished.connect(_on_finished.bind(effect))
	if then.is_valid():
		effect.finished.connect(then)
	add_child(effect)
	set_process(true)


## Ends the effect playing at once, if any.
func finish() -> void:
	if current != null:
		current.finish()


func _process(delta: float) -> void:
	current.advance(delta)
	if current != null:
		jolted.emit(current.jolt())


func _on_finished(effect: MapEffect) -> void:
	current = null
	set_process(false)
	jolted.emit(0.0)
	effect.visible = false
	effect.queue_free()
