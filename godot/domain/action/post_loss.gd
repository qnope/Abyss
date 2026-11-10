class_name PostLoss
extends RefCounted
## lib/domain/action/post_loss.dart: what the owner of a post lost when it
## was taken (PostTakeover).

## The units of the level below, lost with the post.
var units: Dictionary[UnitType.Value, int]
## Whether its passage building stood, and was destroyed.
var passage: bool


func _init(units_: Dictionary[UnitType.Value, int] = {}, passage_ := false) -> void:
	units = units_
	passage = passage_


## `PostLoss.none`, a const instance in Dart: nothing, the post held.
static func none() -> PostLoss:
	return PostLoss.new()
