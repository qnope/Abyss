class_name GuideStorm
extends GuideMessage
## `GuideStorm` of lib/domain/objective/guide/guide_message.dart:
## a storm closes the exploration until the end of `until_turn`.

var until_turn: int


func _init(until_turn_: int) -> void:
	until_turn = until_turn_


func _figures() -> PackedStringArray:
	return PackedStringArray([str(until_turn)])
