class_name ObjectiveProgress
extends RefCounted
## lib/domain/objective/objective_progress.dart: how far a player is on an
## objective, `current` steps out of `target`.

var current: int
var target: int


## `current` is capped at `target`: going further does not show.
func _init(current_: int, target_: int) -> void:
	current = clampi(current_, 0, target_)
	target = target_


## `ObjectiveProgress.flag`: one-step progress, done when `met`.
static func flag(met: bool) -> ObjectiveProgress:
	return ObjectiveProgress.new(1 if met else 0, 1)


func is_done() -> bool:
	return current >= target


## `operator +`: both progresses summed, as one goal made of two.
func plus(other: ObjectiveProgress) -> ObjectiveProgress:
	return ObjectiveProgress.new(current + other.current, target + other.target)


func _to_string() -> String:
	return "%d/%d" % [current, target]
