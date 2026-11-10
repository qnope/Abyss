class_name ObjectiveSamples
extends RefCounted
## What the tests of the objectives take from test/helpers/objective_helpers.dart
## and map_tab_harness.dart: a fresh game on a plain map, a building set to a
## level, the progress of an objective. `setUnits` is RaidSamples.set_units.

## `harnessMapSize`: the side of the square maps of plain_map().
const HARNESS_MAP_SIZE := 10


## `objectiveGame`: a fresh game on a plain map, its player built as a new
## game builds it: base at (5, 5), only the area around it revealed.
static func objective_game() -> Game:
	var player := Player.with_base("Nemo", 5, 5, HARNESS_MAP_SIZE, HARNESS_MAP_SIZE)
	var game := Game.single_player(player)
	game.levels = {1: plain_map()}
	return game


## `plainMap()` of map_tab_harness.dart, without overrides: the cells to
## change are set afterwards.
static func plain_map() -> GameMap:
	return MapSamples.plain_map(HARNESS_MAP_SIZE, HARNESS_MAP_SIZE)


## `setBuilding`: the `type` building of `player` at `level`.
static func set_building(player: Player, type: BuildingType.Value, level: int) -> void:
	player.buildings[type].level = level


## What `expectProgress` compares: the progress of objective `id` for the
## human of `game`, as [current, target, done].
static func progress(game: Game, id: ObjectiveId.Value) -> Array:
	var reached := ObjectiveCatalog.by_id(id).progress_of(game, game.human_player())
	return [reached.current, reached.target, reached.is_done()]


## The `[current, target, done]` `expectProgress` expects.
static func expected(current: int, target: int) -> Array:
	return [current, target, current >= target]
