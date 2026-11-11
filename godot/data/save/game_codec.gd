class_name GameCodec
extends RefCounted
## A whole game in a save: its players in playing order, by id, its levels
## by number, where it stands, its journal and its dates.


static func game(x: Game) -> Dictionary:
	var players := {}
	for id: String in x.players:
		players[id] = PlayerCodec.player(x.players[id])
	return {
		"humanPlayerId": x.human_player_id, "players": players, "turn": x.turn, "createdAt": x.created_at,
		"levels": SaveValues.by_number(x.levels, MapCodec.game_map),
		"status": SaveValues.name(GameStatus.Value, x.status),
		"replay": SaveValues.or_null(x.replay, JournalCodec.journal),
		"difficulty": SaveValues.name(Difficulty.Value, x.saved_difficulty),
		"lastPlayedAt": x.saved_last_played_at,
		"factions": SaveValues.names(x.saved_factions, FactionPersonality.Value),
		"leviathanReturn": SaveValues.or_null(x.leviathan_return, ThreatCodec.leviathan),
	}


## Through the constructor, then the fields Dart's adapter sets after it.
static func read_game(r: SaveReader, value: Variant) -> Game:
	var m := r.object(value, "Game")
	var players: Dictionary[String, Player] = {}
	var players_written := r.object_at(m, "players")
	for id: Variant in players_written:
		players[r.text(id, "players")] = PlayerCodec.read_player(r, players_written[id])
	var levels: Dictionary[int, GameMap] = {}
	var levels_written := r.object_at(m, "levels")
	for level: Variant in levels_written:
		var number := SaveCollections.number_key(r, r.text(level, "levels"), "levels")
		levels[number] = MapCodec.read_game_map(r, levels_written[level])
	var journal: Variant = r.object_or_null_at(m, "replay")
	var found := Game.new(
		r.text_at(m, "humanPlayerId"), players, r.int_at(m, "turn"), r.int_at(m, "createdAt"), levels,
		r.enum_at(m, "status", GameStatus.Value), null if journal == null else JournalCodec.read_journal(r, journal),
		r.enum_at(m, "difficulty", Difficulty.Value), r.int_or_null_at(m, "lastPlayedAt"),
	)
	found.saved_factions.assign(SaveCollections.names_at(r, m, "factions", FactionPersonality.Value))
	var leviathan: Variant = r.object_or_null_at(m, "leviathanReturn")
	found.leviathan_return = null if leviathan == null else ThreatCodec.read_leviathan(r, leviathan)
	return found
