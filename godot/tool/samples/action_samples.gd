class_name ActionSamples
extends RefCounted
## Sample players and games for the tests of the actions: what the Dart
## tests of test/domain/action/ write inline (`Player(id: 'test', name:
## 'Test', resources: {...}, buildings: {...})`) and what their helpers
## build (`*_helper.dart`).

const ALGAE := ResourceType.Value.ALGAE
const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const ENERGY := ResourceType.Value.ENERGY
const PEARL := ResourceType.Value.PEARL


## The player "test" named "Test", holding the stocks and the buildings
## given (each stock under the default storage), and nothing else.
static func stocked(
	amounts: Dictionary[ResourceType.Value, int],
	levels: Dictionary[BuildingType.Value, int],
	recruited: Array[UnitType.Value] = [],
) -> Player:
	return Player.new(
		"Test", "test", 0, 0, DomainSamples.resources(amounts), DomainSamples.buildings(levels),
		null, null, recruited,
	)


## Stocks of the five resources, in the order of ResourceType.
static func amounts(algae: int, coral: int, ore: int, energy: int, pearl: int) -> Dictionary[ResourceType.Value, int]:
	return {ALGAE: algae, CORAL: coral, ORE: ore, ENERGY: energy, PEARL: pearl}


## The game of `player` alone at `turn`.
static func game_of(player: Player, turn := 1) -> Game:
	return Game.new(player.id, {player.id: player}, turn)


## Every unit type, `scouts` scouts and none of the others: the army the
## helpers give a player (`for (final type in UnitType.values) ...`).
static func scouts_only(scouts: int) -> Dictionary[UnitType.Value, Unit]:
	var counts: Dictionary[UnitType.Value, int] = {}
	for type: UnitType.Value in UnitType.Value.values():
		counts[type] = scouts if type == UnitType.Value.SCOUT else 0
	return DomainSamples.units(counts)


## `createExploreScenario`: a 7x7 plain map (seed 42), the player on (3, 3)
## with `scouts` scouts on level 1 and the square around its base revealed.
static func explore_game(scouts := 3, map: GameMap = null, player_id := "test-uuid") -> Game:
	var units: Dictionary[int, Dictionary] = {1: scouts_only(scouts)}
	var revealed: Dictionary[int, Array] = {1: EventSamples.square_around(3, 3, 1)}
	var player := Player.new("Test", player_id, 3, 3, null, null, null, units, [], [], revealed)
	var levels: Dictionary[int, GameMap] = {1: map if map != null else MapSamples.plain_map(7, 7, 42)}
	return Game.new(player.id, {player.id: player}, 1, levels)


## `buildCollectTestMap`: a 5x5 plain map (seed 42) whose cell (1, 1)
## holds `content`, `lair` and `collected_by`.
static func collect_map(
	content := CellContentType.Value.RESOURCE_BONUS, lair: MonsterLair = null, collected_by: Variant = null
) -> GameMap:
	var map := MapSamples.plain_map(5, 5, 42)
	map.cells[6] = MapCell.new(TerrainType.Value.PLAIN, content, lair, collected_by)
	return map


## `buildCollectTestPlayer`: a player on (2, 2) who sees the 25 cells of
## the collect map.
static func collect_player(id := "test-uuid") -> Player:
	var revealed: Dictionary[int, Array] = {1: EventSamples.square_around(2, 2, 2)}
	return Player.new("Test", id, 2, 2, null, null, null, null, [], [], revealed)


## `buildFightTestMap`: a 5x5 plain map (seed 42) whose cell (1, 1) holds
## `content` and, `with_lair`, a lair of `difficulty` and `unit_count`.
static func fight_map(
	difficulty := MonsterDifficulty.Value.EASY, unit_count := 1, collected_by: Variant = null,
	with_lair := true, content := CellContentType.Value.MONSTER_LAIR,
) -> GameMap:
	var lair := MonsterLair.new(difficulty, unit_count) if with_lair else null
	var map := MapSamples.plain_map(5, 5, 42)
	map.cells[6] = MapCell.new(TerrainType.Value.PLAIN, content, lair, collected_by)
	return map


## `buildFightTestPlayer`: a new player on (2, 2) holding `stock` on level
## 1, its military research at `military_level` (unlocked when above 0).
static func fight_player(
	stock: Dictionary[UnitType.Value, int] = {}, military_level := 0, id := "test-uuid"
) -> Player:
	var player := Player.new("Test", id, 2, 2)
	for type: UnitType.Value in stock:
		player.units_on_level(1)[type].count = stock[type]
	if military_level > 0:
		var military: TechBranchState = player.tech_branches[TechBranch.Value.MILITARY]
		military.unlocked = true
		military.research_level = military_level
	return player


## `createFightScenario`: the fight player alone on the fight map.
static func fight_game(
	difficulty := MonsterDifficulty.Value.EASY, unit_count := 1, stock: Dictionary[UnitType.Value, int] = {},
	military_level := 0, collected_by: Variant = null, with_lair := true,
	content := CellContentType.Value.MONSTER_LAIR,
) -> Game:
	var player := fight_player(stock, military_level)
	var levels: Dictionary[int, GameMap] = {
		1: fight_map(difficulty, unit_count, collected_by, with_lair, content)
	}
	return Game.new(player.id, {player.id: player}, 1, levels)


## `createCollectScenario`: the collect player alone on the collect map.
static func collect_game(
	content := CellContentType.Value.RESOURCE_BONUS, lair: MonsterLair = null, collected_by: Variant = null
) -> Game:
	var player := collect_player()
	var levels: Dictionary[int, GameMap] = {1: collect_map(content, lair, collected_by)}
	return Game.new(player.id, {player.id: player}, 1, levels)
