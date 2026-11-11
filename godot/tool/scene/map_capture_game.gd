class_name MapCaptureGame
extends RefCounted
## The game the map capture plays (map_capture.gd): against three factions, the
## surface seen around the base and the rest in the dark, ruins and a treasure
## beside the base, three scouts and one of them on its way, and the other
## depths seen where a passage and the volcano lie.

## How far around the base the surface is seen.
const SEEN := 7
## Where the ruins and the treasure stand, from the base.
const RUINS_AT := Vector2i(1, 0)
const TREASURE_AT := Vector2i(-1, 1)


static func of_three_levels() -> Game:
	var game := GameFactory.new_game("Nemo", 1, Difficulty.Value.NORMAL, false, 3, null, "me")
	var player := game.human_player()
	player.units_per_level[1] = DomainSamples.units({UnitType.Value.SCOUT: 3})
	var base := Vector2i(player.base_x, player.base_y)
	_see(game, 1, base, SEEN)
	game.levels[1].set_cell(base.x + RUINS_AT.x, base.y + RUINS_AT.y, _cell(CellContentType.Value.RUINS))
	var treasure := base + TREASURE_AT
	game.levels[1].set_cell(treasure.x, treasure.y, _cell(CellContentType.Value.RESOURCE_BONUS))
	for passage: Vector2i in MapStates.of(game, 2).passage_holders:
		_see(game, 2, passage, 3)
	_see(game, 3, _volcano(game.levels[3]), 4)
	var scout := Vector2i(base.x - SEEN - 1, base.y)
	player.pending_explorations.append(ExplorationOrder.new(GridPosition.of_key(scout), 1))
	return game


## A cell of the surface next to the cells seen, not seen itself.
static func hidden_next_to_the_seen(game: Game) -> Vector2i:
	var human := game.human_player()
	var seen := human.revealed_cells_set_on_level(1)
	var map := game.levels[1]
	for y in map.height:
		for x in map.width:
			if not seen.has(Vector2i(x, y)) and CellEligibilityChecker.is_eligible(map, human, x, y):
				return Vector2i(x, y)
	return Vector2i.ZERO


static func _cell(content: CellContentType.Value) -> MapCell:
	return MapCell.new(TerrainType.Value.PLAIN, content)


## Shows the square of radius [param radius] around [param centre] on [param level].
static func _see(game: Game, level: int, centre: Vector2i, radius: int) -> void:
	var map: GameMap = game.levels[level]
	for y in range(maxi(centre.y - radius, 0), mini(centre.y + radius + 1, map.height)):
		for x in range(maxi(centre.x - radius, 0), mini(centre.x + radius + 1, map.width)):
			game.human_player().add_revealed_cell(level, GridPosition.new(x, y))


static func _volcano(map: GameMap) -> Vector2i:
	for y in map.height:
		for x in map.width:
			if map.cell_at(x, y).content == CellContentType.Value.VOLCANIC_KERNEL:
				return Vector2i(x, y)
	return Vector2i(int(map.width * 0.5), int(map.height * 0.5))
