class_name WreckEnding
extends RefCounted
## lib/domain/event/effects/wreck_ending.dart: how the wreck of a player left
## the map at the end of a turn.

## True when searched during the turn, false when it sank unsearched.
var searched: bool
## Last turn, inclusive, it could be searched.
var until_turn: int


func _init(searched_: bool, until_turn_: int) -> void:
	searched = searched_
	until_turn = until_turn_
