class_name GuideLeviathanReturn
extends GuideMessage
## `GuideLeviathanReturn` of lib/domain/objective/guide/guide_campaign_messages.dart:
## the guardians come back at the end of the turn to take the Faille,
## held by the units on `level`: `missing` Harpoonists more would make it
## hold, 0 when it should hold or when no number would.

var level: int
var missing: int


func _init(level_: int, missing_ := 0) -> void:
	level = level_
	missing = missing_


func _figures() -> PackedStringArray:
	return PackedStringArray([str(level), str(missing)])
