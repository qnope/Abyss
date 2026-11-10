class_name GuideAdmiralToRecruit
extends GuideMessage
## `GuideAdmiralToRecruit` of lib/domain/objective/guide/guide_campaign_messages.dart:
## no Abyss Admiral to lead the assault on `target`: recruit one.

var target: AssaultTarget.Value


func _init(target_: AssaultTarget.Value) -> void:
	target = target_


func _figures() -> PackedStringArray:
	return PackedStringArray([GuideMessage.enum_text("AssaultTarget", AssaultTarget.Value, target)])
