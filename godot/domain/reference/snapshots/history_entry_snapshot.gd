class_name HistoryEntrySnapshot
extends RefCounted
## lib/domain/reference/snapshots/history_entry_snapshot.dart: builds the
## snapshot of one class of history entries, its turn, its category and its
## own fields. The `title` and `subtitle` Dart leaves out (`legacyTexts`)
## are not in the port's entries (reference/README.md, "Fields left out"),
## so nothing is left out here.


## `own` maps the Dart name of each field of the class to its writer.
static func of(dart_class: String, own: Dictionary[String, Callable]) -> ClassSnapshot:
	var fields: Dictionary[String, Callable] = {
		"turn": func(e: HistoryEntry, _ids: PlayerIds) -> Variant: return e.turn,
		"category": func(e: HistoryEntry, _ids: PlayerIds) -> Variant:
			return SnapshotValues.name(HistoryEntryCategory.Value, e.category),
	}
	fields.merge(own)
	return ClassSnapshot.new(dart_class, fields)
