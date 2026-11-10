extends TestCase
## Not in the Dart files: five new games as the Dart rules make them, read
## by a scratch script run with `dart run` on lib/domain (GameFactory.newGame
## with the same arguments, humanId 'human'). Per game: the factions, then
## each level [level, seed, width, mapFingerprint]; per player in order: id,
## name, base, the cells revealed on level 1 (count, first x y, last x y),
## tutorial and tips. Every player holds the stocks, buildings, branches and
## units of PlayerDefaults, in its order.

const DIGESTS: Dictionary[String, Dictionary] = {
	"solo-3-tutorial": {
		"factions": [],
		"levels": [[1, 3, 20, 2915514293]],
		"players": [["human", "Nemo", 9, 9, 25, 7, 7, 11, 11, true, true]],
	},
	"hard-11-three": {
		"factions": ["currentNomads", "murenaHorde", "wreckPillagers"],
		"levels": [[1, 11, 26, 501195491], [2, 1140900365, 26, 2374841255], [3, 390537999, 26, 734021487]],
		"players": [
			["human", "Nemo", 11, 13, 25, 9, 11, 13, 15, false, false],
			["faction-currentNomads", "Les Nomades du Courant", 23, 20, 25, 21, 18, 25, 22, false, false],
			["faction-murenaHorde", "La Horde des Murènes", 14, 2, 25, 12, 0, 16, 4, false, false],
			["faction-wreckPillagers", "Les Pillards de l'Épave", 8, 23, 25, 6, 21, 10, 25, false, false],
		],
	},
	"easy-24-two": {
		"factions": ["krakenFaithful", "murenaHorde"],
		"levels": [[1, 24, 20, 3517897433], [2, 107383538, 20, 2387647787], [3, 115667701, 20, 4239721102]],
		"players": [
			["human", "Ana", 10, 11, 25, 8, 9, 12, 13, true, true],
			["faction-krakenFaithful", "Les Fidèles du Kraken", 4, 2, 25, 2, 0, 6, 4, false, false],
			["faction-murenaHorde", "La Horde des Murènes", 15, 3, 25, 13, 1, 17, 5, false, false],
		],
	},
	"normal-7-ten": {
		"factions": [
			"anglerCult", "pyrosomeHive", "currentNomads", "krakenFaithful", "wreckPillagers",
			"magmaSmiths", "murenaHorde", "siphonophoreGuild", "pearlOrder", "silenceMonks",
		],
		"levels": [[1, 7, 32, 2438078256], [2, 458359284, 32, 3843839114], [3, 938956728, 32, 3507090692]],
		"players": [
			["human", "Nemo", 14, 16, 25, 12, 14, 16, 18, false, false],
			["faction-anglerCult", "Le Culte de la Baudroie", 28, 19, 25, 26, 17, 30, 21, false, false],
			["faction-pyrosomeHive", "La Ruche des Pyrosomes", 29, 3, 25, 27, 1, 31, 5, false, false],
			["faction-currentNomads", "Les Nomades du Courant", 9, 3, 25, 7, 1, 11, 5, false, false],
			["faction-krakenFaithful", "Les Fidèles du Kraken", 9, 28, 25, 7, 26, 11, 30, false, false],
			["faction-wreckPillagers", "Les Pillards de l'Épave", 2, 15, 25, 0, 13, 4, 17, false, false],
			["faction-magmaSmiths", "Les Forgerons du Magma", 19, 27, 25, 17, 25, 21, 29, false, false],
			["faction-murenaHorde", "La Horde des Murènes", 18, 5, 25, 16, 3, 20, 7, false, false],
			["faction-siphonophoreGuild", "La Guilde des Siphonophores", 28, 28, 25, 26, 26, 30, 30, false, false],
			["faction-pearlOrder", "L'Ordre de Nacre", 2, 25, 25, 0, 23, 4, 27, false, false],
			["faction-silenceMonks", "Les Moines du Silence", 22, 12, 25, 20, 10, 24, 14, false, false],
		],
	},
	"chosen-5": {
		"factions": ["krakenFaithful", "pearlOrder"],
		"levels": [[1, 5, 20, 1245248087], [2, 208735773, 20, 3491545007], [3, 700087277, 20, 3831804058]],
		"players": [
			["human", "Nemo", 11, 8, 25, 9, 6, 13, 10, false, false],
			["faction-krakenFaithful", "Les Fidèles du Kraken", 16, 16, 25, 14, 14, 18, 18, false, false],
			["faction-pearlOrder", "L'Ordre de Nacre", 3, 10, 25, 1, 8, 5, 12, false, false],
		],
	},
}
const STOCKS := [["algae", 100, 5000], ["coral", 300, 5000], ["ore", 150, 5000], ["energy", 100, 2000], ["pearl", 5, 100]]


func test_makes_the_games_dart_makes() -> void:
	var kraken_and_pearl: Array[FactionPersonality.Value] = [
		FactionPersonality.Value.KRAKEN_FAITHFUL, FactionPersonality.Value.PEARL_ORDER,
	]
	var games: Dictionary[String, Game] = {
		"solo-3-tutorial": _new("Nemo", 3, Difficulty.Value.NORMAL, true, 0),
		"hard-11-three": _new("Nemo", 11, Difficulty.Value.HARD, false, 3),
		"easy-24-two": _new("Ana", 24, Difficulty.Value.EASY, true, 2),
		"normal-7-ten": _new("Nemo", 7, Difficulty.Value.NORMAL, false, 10),
		"chosen-5": _new("Nemo", 5, Difficulty.Value.NORMAL, false, 0, kraken_and_pearl),
	}
	for name: String in games:
		var game := games[name]
		assert_eq(_digest(game), DIGESTS[name], name)
		assert_eq([game.replay.map_seed, game.replay.player_name], [DIGESTS[name]["levels"][0][1], game.players["human"].name])
		for player: Player in game.players.values():
			_assert_defaults(player, "%s, %s" % [name, player.id])
	assert_eq(games["easy-24-two"].difficulty(), Difficulty.Value.EASY)


func _new(name: String, seed_: int, difficulty: Difficulty.Value, tutorial: bool, count: int, chosen: Variant = null) -> Game:
	return GameFactory.new_game(name, seed_, difficulty, tutorial, count, chosen, "human")


func _digest(game: Game) -> Dictionary:
	var levels: Array = []
	for level: int in game.levels:
		var map := game.levels[level]
		levels.append([level, map.map_seed, map.width, MapSamples.fingerprint(map)])
	var players: Array = []
	for player: Player in game.players.values():
		var cells := player.revealed_cells_on_level(1)
		var objectives := player.saved_objective_state
		players.append([
			player.id, player.name, player.base_x, player.base_y, cells.size(), cells[0].x, cells[0].y,
			cells[-1].x, cells[-1].y, objectives.tutorial_enabled, objectives.tips_enabled,
		])
	var factions := game.factions().map(func(f: Faction) -> String: return DartEnum.name_of(FactionPersonality.Value, f.personality))
	return {"factions": factions, "levels": levels, "players": players}


func _assert_defaults(player: Player, label: String) -> void:
	var stocks := player.resources.values().map(
		func(r: GameResource) -> Array: return [DartEnum.name_of(ResourceType.Value, r.type), r.amount, r.max_storage]
	)
	assert_eq(stocks, STOCKS, label)
	assert_eq(player.buildings.keys(), BuildingType.Value.values(), label)
	assert_eq(player.tech_branches.keys(), TechBranch.Value.values(), label)
	assert_eq(player.units_per_level.keys(), [1], label)
	assert_eq(player.units_on_level(1).keys(), UnitType.Value.values(), label)
	assert_eq(player.revealed_cells_per_level.keys(), [1], label)
