class_name GuideAdmiralNeedsBarracks
extends GuideMessage
## `GuideAdmiralNeedsBarracks` of lib/domain/objective/guide/guide_campaign_messages.dart:
## no Abyss Admiral to lead the assault on `target`: the barracks must
## reach `barracks_level` to recruit one.

var target: AssaultTarget.Value
var barracks_level: int


func _init(target_: AssaultTarget.Value, barracks_level_: int) -> void:
	target = target_
	barracks_level = barracks_level_


func _figures() -> PackedStringArray:
	return PackedStringArray([
		GuideMessage.enum_text("AssaultTarget", AssaultTarget.Value, target),
		str(barracks_level),
	])
