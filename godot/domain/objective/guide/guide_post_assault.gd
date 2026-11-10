class_name GuidePostAssault
extends GuideMessage
## `GuidePostAssault` of lib/domain/objective/guide/guide_campaign_messages.dart:
## a `target` in sight: send the admiral, covered by Guardians, with at
## least `harpoonists` Harpoonists (an int), null when no number would do.

var target: AssaultTarget.Value
var harpoonists: Variant


func _init(target_: AssaultTarget.Value, harpoonists_: Variant = null) -> void:
	target = target_
	harpoonists = harpoonists_


func _figures() -> PackedStringArray:
	return PackedStringArray([
		GuideMessage.enum_text("AssaultTarget", AssaultTarget.Value, target),
		GuideMessage.or_minus_one(harpoonists),
	])
