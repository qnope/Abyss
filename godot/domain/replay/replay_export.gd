class_name ReplayExport
extends RefCounted
## lib/domain/replay/replay_export.dart: turns a game's ReplayJournal into a
## JSON scenario that `ScenarioParser` reads and `bin/simulate.dart` plays
## headless:
##
##     {
##       "name": "replay-qnope-tour-12",
##       "player": "qnope",
##       "mapSeed": 1234,
##       "lastTurn": 12,
##       "exact": true,
##       "turns": {"1": [{"do": "upgrade", "building": "algaeFarm"}]},
##       "endTurnSeeds": {"1": 98765}
##     }
##
## Against factions, `factions` names their personalities in playing order.
## With several players, `players` lists them (`id`, `name`) and the actions
## of the others carry `"player": "<id>"`, in the order they were played.


## Whether `game` kept a journal; games started before it existed did not.
static func can_export(game: Game) -> bool:
	return game.replay != null


## Whether the replay plays `game` exactly: every die recorded, and the game
## no older than the Léviathan return and the gentler first volcano wave
## (`leviathan_return` set), which the game its replay rebuilds has.
static func is_exact(game: Game) -> bool:
	return game.replay.exact and game.leviathan_return != null


static func to_json(game: Game) -> Dictionary:
	var journal := game.replay
	var turns: Array[int] = journal.actions.keys()
	turns.sort()
	var ends: Array[int] = journal.end_turn_seeds.keys()
	ends.sort()
	var json := {"name": file_name(game).replace(".json", ""), "player": journal.player_name}
	if game.players.size() > 1:
		var players: Array[Dictionary] = []
		for p: Player in game.players.values():
			players.append({"id": p.id, "name": p.name})
		json["players"] = players
	if not game.factions().is_empty():
		var factions: Array[String] = []
		for f: Faction in game.factions():
			factions.append(DartEnum.name_of(FactionPersonality.Value, f.personality))
		json["factions"] = factions
	json["mapSeed"] = journal.map_seed
	json["difficulty"] = DartEnum.name_of(Difficulty.Value, game.difficulty())
	json["lastTurn"] = game.turn
	json["exact"] = is_exact(game)
	json["status"] = DartEnum.name_of(GameStatus.Value, game.status)
	var moves := {}
	for t: int in turns:
		moves[str(t)] = journal.actions_of(t)
	json["turns"] = moves
	var seeds := {}
	for t: int in ends:
		seeds[str(t)] = journal.end_turn_seeds[t]
	json["endTurnSeeds"] = seeds
	return json


## The scenario, indented so it reads well once shared, as Dart's
## `JsonEncoder.withIndent('  ')` writes it.
static func to_text(game: Game) -> String:
	return JSON.stringify(to_json(game), "  ", false)


static func file_name(game: Game) -> String:
	var player := game.replay.player_name if game.replay != null else "partie"
	var safe := RegEx.create_from_string("[^A-Za-z0-9_-]").sub(player, "_", true)
	return "replay-%s-tour-%d.json" % [safe, game.turn]
