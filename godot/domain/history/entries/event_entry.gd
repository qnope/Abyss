class_name EventEntry
extends HistoryEntry
## lib/domain/history/entries/event_entry.dart: history entry recording how a
## random event played out: the player's choice, or the prudent option when
## the turn ended without one. The presentation titles it after its `type`
## and words the choice. Without the `title` and `subtitle` of the Dart
## class, always empty and null.

var type: RandomEventType.Value
## Whether the event was accepted; always true for an event drawn without a
## choice.
var accepted: bool
## Whether the prudent option applied because the player did not choose.
var defaulted: bool


func _init(turn_: int, type_: RandomEventType.Value, accepted_: bool, defaulted_: bool) -> void:
	super(turn_, HistoryEntryCategory.Value.EVENT)
	type = type_
	accepted = accepted_
	defaulted = defaulted_
