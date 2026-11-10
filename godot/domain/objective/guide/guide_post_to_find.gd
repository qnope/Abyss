class_name GuidePostToFind
extends GuideMessage
## `GuidePostToFind` of lib/domain/objective/guide/guide_campaign_messages.dart:
## no `target` in sight yet: explore to find one.

var target: AssaultTarget.Value


func _init(target_: AssaultTarget.Value) -> void:
	target = target_


func _figures() -> PackedStringArray:
	return PackedStringArray([GuideMessage.enum_text("AssaultTarget", AssaultTarget.Value, target)])
