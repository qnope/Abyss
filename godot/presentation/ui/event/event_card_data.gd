class_name EventCardData
extends RefCounted
## Everything an event card shows: the event, two lines telling what happens
## and its choices, none for an event that only informs
## (lib/presentation/widgets/event/event_card_data.dart).

var type: RandomEventType.Value
## Two short lines under the title.
var lines: PackedStringArray
## The first option then the prudent one, or empty.
var choices: Array[EventChoice]


func _init(type_: RandomEventType.Value, lines_: PackedStringArray, choices_: Array[EventChoice] = []) -> void:
	type = type_
	lines = lines_
	choices = choices_


## The card of [param type] for the human player of [param game], with the
## figures of the current turn, in the language on.
static func of(game: Game, type_: RandomEventType.Value) -> EventCardData:
	var texts := EventCardTexts.new(game, game.human_player())
	return EventCardData.new(type_, texts.lines_of(type_), texts.choices_of(type_))
