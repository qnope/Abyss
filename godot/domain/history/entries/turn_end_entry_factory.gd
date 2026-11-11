class_name TurnEndEntryFactory
extends RefCounted
## lib/domain/history/entries/turn_end_entry_factory.dart: builds a
## TurnEndEntry from a TurnResult, kept apart so that TurnEndEntry stays a
## plain data class.


## The entry of `turn` for `result`: read-only copies of its changes, its
## buildings shut down and its units lost. The turn is given because a
## TurnResult carries both the previous and the new one, and the caller
## decides which one the entry belongs to.
func from_turn_result(turn: int, result: TurnResult) -> TurnEndEntry:
	var changes := result.changes.duplicate()
	changes.make_read_only()
	var deactivated := result.deactivated_buildings.duplicate()
	deactivated.make_read_only()
	var lost := result.lost_units.duplicate()
	lost.make_read_only()
	return TurnEndEntry.new(turn, changes, deactivated, lost)
