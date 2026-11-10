class_name GuideWreck
extends GuideMessage
## `GuideWreck` of lib/domain/objective/guide/guide_message.dart:
## a wreck lies on the map until the end of `until_turn`, out of reach:
## with no barracks yet (`has_barracks` false), or with no scout.

var until_turn: int
var has_barracks: bool


func _init(until_turn_: int, has_barracks_: bool) -> void:
	until_turn = until_turn_
	has_barracks = has_barracks_


func _figures() -> PackedStringArray:
	return PackedStringArray([str(until_turn), str(has_barracks)])
