class_name RandomEventChoice
extends RefCounted
## lib/domain/event/random_event_choice.dart: whether the player decides how
## an event plays out (an extension of RandomEventType in Dart).


## Every event waits for a choice but the storm, which applies as soon as it
## is drawn, and the wreck, sunk on the map for the player to go and search
## or not.
static func has_choice(type: RandomEventType.Value) -> bool:
	return type != RandomEventType.Value.STORM and type != RandomEventType.Value.WRECK
