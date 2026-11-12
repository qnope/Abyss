class_name ModelAnimator
extends RefCounted
## Plays the animations of an imported model by name: the AnimationPlayer
## that the glb's importer put in its scene, with the actions of
## tool/models (`idle`, `swim`, `attack`, `hit`...; the ones the script marked
## as loops loop). The model stands in `idle`; a one-shot action ends by
## giving back to it. A model with no animation (a building) is a model with
## nothing to play: every call says so and does nothing.
##
## It is held beside the model it animates and freed with it; the model must be
## in the tree for time to run.

## The pose a model rests in.
const IDLE := &"idle"
## How long a change of action blends, in seconds.
const BLEND := 0.15

var player: AnimationPlayer


func _init(model: Node) -> void:
	var found := model.find_children("*", "AnimationPlayer", true, false)
	if found.is_empty():
		return
	player = found[0] as AnimationPlayer
	player.playback_default_blend_time = BLEND
	if player.has_animation(IDLE):
		player.play(IDLE)


## Whether the model has an animation to play.
func is_animated() -> bool:
	return player != null


## The names of the model's animations, in alphabetical order.
func animations() -> Array[StringName]:
	var names: Array[String] = []
	if player != null:
		for animation in player.get_animation_list():
			names.append(String(animation))
	names.sort()
	var sorted_names: Array[StringName] = []
	for animation in names:
		sorted_names.append(StringName(animation))
	return sorted_names


func has_animation(animation: StringName) -> bool:
	return player != null and player.has_animation(animation)


## Plays [param animation] at [param speed] (1 is the model's own); a looping
## one goes on until another is played, any other ends by giving back to
## `idle`. False, and nothing changed, when the model has no such animation.
func play(animation: StringName, speed := 1.0) -> bool:
	if not has_animation(animation):
		return false
	player.play(animation, -1.0, speed)
	if animation != IDLE and player.has_animation(IDLE) \
			and player.get_animation(animation).loop_mode == Animation.LOOP_NONE:
		player.queue(IDLE)
	return true


## The animation playing now, or an empty name when none is.
func current() -> StringName:
	return StringName(player.current_animation) if player != null else &""


## Whether [param animation] ends by itself (an action) and does not loop.
func is_one_shot(animation: StringName) -> bool:
	return has_animation(animation) and player.get_animation(animation).loop_mode == Animation.LOOP_NONE


## How long [param animation] lasts at its own speed, in seconds; 0 when the
## model has none.
func length_of(animation: StringName) -> float:
	return player.get_animation(animation).length if has_animation(animation) else 0.0
