class_name EventInputs
extends RefCounted
## Reads what a case of reference/vectors/events.json writes: an event or
## none, a set of events, the lasting effect of an EventState. The twin of
## the reads of tool/vectors/domain/event_vectors.dart.


## The RandomEventType.Value a case names, or null for its null.
static func event_or_null(name: Variant) -> Variant:
	if name == null:
		return null
	return VectorInputs.value(RandomEventType.Value, name)


## A set of events, written as the list of their names, in its order.
static func events(names: Variant) -> Dictionary[RandomEventType.Value, bool]:
	var listed: Array = names
	var members: Dictionary[RandomEventType.Value, bool] = {}
	for name: String in listed:
		members[VectorInputs.value(RandomEventType.Value, name) as RandomEventType.Value] = true
	return members


## `EventState(active: active, activeUntilTurn: until, heating: heating)`.
static func state(case: Dictionary) -> EventState:
	var heating: bool = case["heating"]
	return EventState.new(null, null, null, null, event_or_null(case["active"]), case["until"], heating)
