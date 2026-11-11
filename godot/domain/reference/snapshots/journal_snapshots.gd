class_name JournalSnapshots
extends RefCounted
## lib/domain/reference/snapshots/journal_snapshots.dart: snapshot of the
## journal a game keeps of its own moves.


## The actions are decoded, each one the list of its pairs in the order the
## journal wrote them (`do` first; the units in the order they were sent),
## so no JSON layout is part of the snapshot.
static func journal() -> ClassSnapshot:
	var same := func(value: int) -> Variant: return value
	return ClassSnapshot.new("ReplayJournal", {
		"mapSeed": func(j: ReplayJournal, _ids: PlayerIds) -> Variant: return j.map_seed,
		"playerName": func(j: ReplayJournal, _ids: PlayerIds) -> Variant: return j.player_name,
		"actions": func(j: ReplayJournal, _ids: PlayerIds) -> Variant:
			var turns: Array = []
			for turn: int in j.actions:
				turns.append([turn, SnapshotValues.ordered(Array(j.actions_of(turn)))])
			return turns,
		"endTurnSeeds": func(j: ReplayJournal, _ids: PlayerIds) -> Variant:
			return SnapshotValues.pairs(j.end_turn_seeds, same, same),
		"exact": func(j: ReplayJournal, _ids: PlayerIds) -> Variant: return j.exact,
	})
