class_name GuidePostUndefended
extends GuideMessage
## `GuidePostUndefended` of lib/domain/objective/guide/guide_campaign_messages.dart:
## a post of `type` is held with nobody on `level`, the only units that
## defend it.

var type: TransitionBaseType.Value
var level: int


func _init(type_: TransitionBaseType.Value, level_: int) -> void:
	type = type_
	level = level_


func _figures() -> PackedStringArray:
	return PackedStringArray([
		GuideMessage.enum_text("TransitionBaseType", TransitionBaseType.Value, type),
		str(level),
	])
