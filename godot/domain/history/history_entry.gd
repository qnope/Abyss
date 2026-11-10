class_name HistoryEntry
extends RefCounted
## lib/domain/history/history_entry.dart: the base of all history entries.
## Each player action and end-of-turn event produces a concrete subclass,
## one file each under entries/ (the `part` files of the Dart library).
##
## Entries hold data only: the presentation words their title and subtitle
## in the player's language. Dart declares `turn` and `category` as getters
## each subclass backs with a field; here the base holds both, set by the
## `_init` of the subclass.

var turn: int
var category: HistoryEntryCategory.Value


func _init(turn_: int, category_: HistoryEntryCategory.Value) -> void:
	turn = turn_
	category = category_
