class_name GuideLesson
extends GuideMessage
## `GuideLesson` of lib/domain/objective/guide/guide_message.dart:
## the lesson of the tutorial objective `objective`.

var objective: ObjectiveId.Value


func _init(objective_: ObjectiveId.Value) -> void:
	objective = objective_


func _figures() -> PackedStringArray:
	return PackedStringArray([GuideMessage.enum_text("ObjectiveId", ObjectiveId.Value, objective)])
