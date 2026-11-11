class_name GameSnapshots
extends RefCounted
## lib/domain/reference/snapshots/game_snapshots.dart: snapshot of what a
## game holds besides its players and its maps, which GameSnapshot writes in
## sections of their own.


static func game() -> ClassSnapshot:
	var journals := JournalSnapshots.journal()
	var returns := ThreatSnapshots.leviathan()
	return ClassSnapshot.new("Game", {
		"humanPlayerId": func(g: Game, ids: PlayerIds) -> Variant: return ids.of(g.human_player_id),
		"turn": func(g: Game, _ids: PlayerIds) -> Variant: return g.turn,
		"status": func(g: Game, _ids: PlayerIds) -> Variant: return SnapshotValues.name(GameStatus.Value, g.status),
		"replay": func(g: Game, ids: PlayerIds) -> Variant: return journals.or_null(g.replay, ids),
		"savedDifficulty": func(g: Game, _ids: PlayerIds) -> Variant: return SnapshotValues.name(Difficulty.Value, g.difficulty()),
		"savedFactions": func(g: Game, _ids: PlayerIds) -> Variant:
			return SnapshotValues.names(g.saved_factions, FactionPersonality.Value),
		"leviathanReturn": func(g: Game, ids: PlayerIds) -> Variant: return returns.or_null(g.leviathan_return, ids),
	}, {"savedDifficulty": "difficulty", "savedFactions": "factions"}, {
		"players": "written by the sections of the players, one per group of Player fields (SnapshotSections.OF_PLAYERS)",
		"levels": "written by the sections map1, map2 and map3",
		"createdAt": "wall-clock date the game started; only the list of saves reads it",
		"savedLastPlayedAt": "wall-clock date of the last save; only the list of saves reads it",
	})
