class_name RandomEventTexts
extends RefCounted
## lib/presentation/extensions/random_event_type_extensions.dart
## (RandomEventTypeDisplay): the name of a random event in the language on and
## the illustration of its card, an interface icon of `assets/icons/events/`.


## `type.label(l10n)`: "Courant chaud".
static func label(type: RandomEventType.Value) -> String:
	return Texts.t(TextKeys.of("randomEvent", RandomEventType.Value, type, "Label"))


## `type.illustration`: the file of the event's picture.
static func illustration(type: RandomEventType.Value) -> String:
	var file := DartEnum.name_of(RandomEventType.Value, type).to_snake_case()
	return UiIcon.path_of(&"events", StringName(file))
