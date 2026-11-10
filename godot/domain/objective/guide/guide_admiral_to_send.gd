class_name GuideAdmiralToSend
extends GuideMessage
## `GuideAdmiralToSend` of lib/domain/objective/guide/guide_campaign_messages.dart:
## the Abyss Admiral must go down to `level` to assault `target`; it is
## on `from`, and goes down by the post held there.

var target: AssaultTarget.Value
var level: int
var from: int


func _init(target_: AssaultTarget.Value, level_: int, from_: int) -> void:
	target = target_
	level = level_
	from = from_


func _figures() -> PackedStringArray:
	return PackedStringArray([
		GuideMessage.enum_text("AssaultTarget", AssaultTarget.Value, target),
		str(level),
		str(from),
	])
