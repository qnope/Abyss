class_name JournalCodec
extends RefCounted
## The journal of a game's moves, in a save. Each move stays the JSON text
## the journal recorded, kept to the character: a replay reads it again.


static func journal(x: ReplayJournal) -> Dictionary:
	var same := func(value: Variant) -> Variant: return value
	var texts := func(moves: Array) -> Variant: return moves.duplicate()
	return {
		"mapSeed": x.map_seed, "playerName": x.player_name, "actions": SaveValues.by_number(x.actions, texts),
		"endTurnSeeds": SaveValues.by_number(x.end_turn_seeds, same), "exact": x.exact,
	}


static func read_journal(r: SaveReader, value: Variant) -> ReplayJournal:
	var m := r.object(value, "ReplayJournal")
	var actions: Dictionary[int, Array] = {}
	var written := r.object_at(m, "actions")
	for turn: Variant in written:
		var moves: Array[String] = []
		for move: Variant in r.list(written[turn], "actions"):
			moves.append(r.text(move, "actions"))
		actions[SaveCollections.number_key(r, r.text(turn, "actions"), "actions")] = moves
	var seeds: Dictionary[int, int] = {}
	var seeds_written := r.object_at(m, "endTurnSeeds")
	for turn: Variant in seeds_written:
		var key := SaveCollections.number_key(r, r.text(turn, "endTurnSeeds"), "endTurnSeeds")
		seeds[key] = r.whole(seeds_written[turn], "endTurnSeeds")
	return ReplayJournal.new(r.int_at(m, "mapSeed"), r.text_at(m, "playerName"), actions, seeds, r.bool_at(m, "exact"))
