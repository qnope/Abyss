class_name MapSheetCase
extends UiTestCase
## The base of the tests of the map's sheets (test/helpers/map_tab_harness.dart):
## a single-player game on a square map of bare plain cells, the player's base
## at (5, 5), the cells seen to choose and the scouts to give, with its actions.

const SIZE := 10
const Content := CellContentType.Value
const Scout := UnitType.Value.SCOUT

var game: Game
var human: Player
var actions: GameActions


func before_each() -> void:
	start()


func after_each() -> void:
	# A test listens to the actions with a function of its own: let go of them.
	actions = null


## A new game on the map of [param overrides] (cells by position over bare
## ones), with every cell seen but [param hidden] and [param scouts] scouts.
func start(overrides: Dictionary[Vector2i, MapCell] = {}, hidden: Array[Vector2i] = [],
		scouts := 0) -> void:
	var map := MapSamples.plain_map(SIZE, SIZE)
	for at: Vector2i in overrides:
		map.set_cell(at.x, at.y, overrides[at])
	human = Player.new("Nemo", "me", 5, 5)
	var seen: Array[GridPosition] = []
	for y in SIZE:
		for x in SIZE:
			if not hidden.has(Vector2i(x, y)):
				seen.append(GridPosition.new(x, y))
	human.revealed_cells_per_level[1] = seen
	give_scouts(scouts)
	game = Game.single_player(human)
	var levels: Dictionary[int, GameMap] = {1: map}
	game.levels = levels
	actions = GameActions.new(game)


## Leaves the player [param count] scouts on the first level.
func give_scouts(count: int) -> void:
	human.units_per_level[1] = DomainSamples.units({Scout: count})


## Leaves only [param cells] seen on the first level.
func see_only(cells: Array[Vector2i]) -> void:
	var seen: Array[GridPosition] = []
	for at in cells:
		seen.append(GridPosition.new(at.x, at.y))
	human.revealed_cells_per_level[1] = seen


## A cell holding [param content], with [param changes] (see `copy_with`).
func cell_of(content: Content, changes := {}) -> MapCell:
	return MapCell.new(TerrainType.Value.PLAIN, content).copy_with(changes)


## The stock of [param resource] of the player.
func stock(resource: ResourceType.Value) -> int:
	return human.resources[resource].amount
