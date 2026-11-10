class_name GuidePassageNeedsHq
extends GuideMessage
## `GuidePassageNeedsHq` of lib/domain/objective/guide/guide_campaign_messages.dart:
## the `passage` building needs the headquarters at `headquarters`.

var passage: BuildingType.Value
var headquarters: int


func _init(passage_: BuildingType.Value, headquarters_: int) -> void:
	passage = passage_
	headquarters = headquarters_


func _figures() -> PackedStringArray:
	return PackedStringArray([
		GuideMessage.enum_text("BuildingType", BuildingType.Value, passage),
		str(headquarters),
	])
