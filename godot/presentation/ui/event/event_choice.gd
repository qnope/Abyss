class_name EventChoice
extends RefCounted
## One button of an event card: the option and what it does, in figures
## (lib/presentation/widgets/event/event_choice.dart).

## e.g. "Échanger 100 Algues contre 70 Minerai".
var label: String
## Whether it takes the first option, otherwise the prudent one.
var accept: bool
## Why the option is closed now, or null when it is open.
var refusal: Variant


func _init(label_: String, accept_: bool, refusal_: Variant = null) -> void:
	label = label_
	accept = accept_
	refusal = refusal_
