class_name GuideAdmiralFell
extends GuideMessage
## `GuideAdmiralFell` of lib/domain/objective/guide/guide_campaign_messages.dart:
## an assault on `target` won this turn while the admiral fell: nothing
## was taken.

var target: AssaultTarget.Value


func _init(target_: AssaultTarget.Value) -> void:
	target = target_


func _figures() -> PackedStringArray:
	return PackedStringArray([GuideMessage.enum_text("AssaultTarget", AssaultTarget.Value, target)])
