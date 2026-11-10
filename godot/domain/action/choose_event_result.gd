class_name ChooseEventResult
extends ActionResult
## lib/domain/action/choose_event_result.dart: outcome of choosing for a
## random event: the event settled.

var event: RandomEventType.Value


func _init(event_: RandomEventType.Value) -> void:
	super(null)
	event = event_


## `ChooseEventResult.success(event)`; its parameter takes a default
## (domain/README.md, "Abstract classes").
static func success(event_ := RandomEventType.Value.SURVIVORS) -> ChooseEventResult:
	return ChooseEventResult.new(event_)
