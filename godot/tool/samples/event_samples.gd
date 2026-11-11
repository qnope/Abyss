class_name EventSamples
extends RefCounted
## The players, games and maps the Dart tests of the random events build
## with test/domain/event/event_test_helper.dart,
## effects/wreck_test_helper.dart and effects/predators_test_helper.dart.


## `eventPlayer`: a player with no event scheduled, pending or active yet.
static func event_player() -> Player:
	return Player.new("Test", "p1")


## `eventGame`: the single-player game of `player` during `turn`.
static func event_game(player: Player, turn := 1) -> Game:
	var game := Game.single_player(player)
	game.turn = turn
	return game


## `wreckMap`: a plain `size` x `size` map, every cell empty but those of
## `contents`, keyed by GridPosition.key().
static func wreck_map(
	size := 9, contents: Dictionary[Vector2i, CellContentType.Value] = {}
) -> GameMap:
	var cells: Array[MapCell] = []
	for y: int in size:
		for x: int in size:
			var content: CellContentType.Value = contents.get(Vector2i(x, y), CellContentType.Value.EMPTY)
			cells.append(MapCell.new(TerrainType.Value.PLAIN, content))
	return GameMap.new(size, size, cells, 7)


## `squareAround`: the cells at most `radius` away from (cx, cy), in
## row-major order.
static func square_around(cx: int, cy: int, radius: int) -> Array[GridPosition]:
	var cells: Array[GridPosition] = []
	for y: int in range(cy - radius, cy + radius + 1):
		for x: int in range(cx - radius, cx + radius + 1):
			cells.append(GridPosition.new(x, y))
	return cells


## `wreckRing`: the hidden ring around the 3x3 square wreck_player()
## reveals.
static func wreck_ring() -> Array[GridPosition]:
	var ring: Array[GridPosition] = []
	for p: GridPosition in square_around(4, 4, 2):
		if absi(p.x - 4) == 2 or absi(p.y - 4) == 2:
			ring.append(p)
	return ring


## `wreckPlayer`: a player based at (4, 4) who revealed `revealed`, by
## default the 3x3 square around the base, with `scouts` scouts on level 1.
## No draw is scheduled before turn 100.
static func wreck_player(revealed: Variant = null, scouts := 1) -> Player:
	var cells: Array[GridPosition] = square_around(4, 4, 1) if revealed == null else revealed
	var units: Dictionary[UnitType.Value, Unit] = {}
	for type: UnitType.Value in UnitType.Value.values():
		units[type] = Unit.new(type, scouts if type == UnitType.Value.SCOUT else 0)
	var units_per_level: Dictionary[int, Dictionary] = {1: units}
	var revealed_per_level: Dictionary[int, Array] = {1: cells}
	var player := Player.new(
		"Test", "p1", 4, 4, null, null, null, units_per_level, [], [], revealed_per_level
	)
	player.event_state.schedule(100)
	return player


## `wreckGame`: the single-player game of `player` on `map` (wreck_map()
## when null) during `turn`.
static func wreck_game(player: Player, map: GameMap = null, turn := 12) -> Game:
	var game := Game.single_player(player)
	game.levels = {1: map if map != null else wreck_map()}
	game.turn = turn
	return game


## `eventEntriesOf`: the event entries of `player`'s history, oldest
## first.
static func event_entries_of(player: Player) -> Array[EventEntry]:
	var entries: Array[EventEntry] = []
	for e: HistoryEntry in player.history_entries:
		if e is EventEntry:
			entries.append(e as EventEntry)
	return entries


## `predatorTestWave`: the wave of the predators waiting in the tests.
static func predator_test_wave() -> MonsterLair:
	return MonsterLair.new(
		MonsterDifficulty.Value.EASY, 3, MonsterFamily.Value.SWARM, MonsterFamily.Value.HUNTER, 2
	)


## `threatenedPlayer`: RaidSamples.raid_player whose predators, drawn at the
## end of turn 11 with `wave` (predator_test_wave() when null), wait for a
## choice during turn 12.
static func threatened_player(
	units: Dictionary[UnitType.Value, int] = {}, citadel_level := 0, wave: MonsterLair = null
) -> Player:
	var player := RaidSamples.raid_player(units, citadel_level)
	player.event_state.schedule(100)
	player.event_state.set_pending(RandomEventType.Value.PREDATORS, 12)
	player.event_state.predator_wave = wave if wave != null else predator_test_wave()
	return player


## `producingPlayer`: a player "p1" whose farm, mine and extractor stand at
## 3, its Solar Panels at 6 and its headquarters at 10, high enough that
## none of them is degraded.
static func producing_player(id := "p1") -> Player:
	var buildings := PlayerDefaults.buildings()
	for type: BuildingType.Value in [
		BuildingType.Value.HEADQUARTERS, BuildingType.Value.ALGAE_FARM,
		BuildingType.Value.CORAL_MINE, BuildingType.Value.ORE_EXTRACTOR,
	]:
		buildings[type] = Building.new(type, 3)
	buildings[BuildingType.Value.HEADQUARTERS].level = 10
	buildings[BuildingType.Value.SOLAR_PANEL] = Building.new(BuildingType.Value.SOLAR_PANEL, 6)
	return Player.new("Test", id, 0, 0, null, buildings)
