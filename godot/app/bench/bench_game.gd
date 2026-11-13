class_name BenchGame
extends RefCounted
## The game whose map a bench measures: the same each time, a few turns into
## a game against three factions, the surface seen around the base and the
## other levels seen where a passage and the volcano lie, the rest in the fog.

## How far around the base the surface is seen, and around the other spots.
const SEEN := 7
const SEEN_BELOW := 3
const SEED := 1


## The map of [param level] of that game, as the map tab shows it.
static func map_of(level: int) -> MapLevelState:
	var game := GameFactory.new_game("Bench", SEED, Difficulty.Value.NORMAL, false, 3, null, "me")
	var human := game.human_player()
	_see(game, 1, Vector2i(human.base_x, human.base_y), SEEN)
	for passage: Vector2i in MapStates.of(game, 2).passage_holders:
		_see(game, 2, passage, SEEN_BELOW)
	_see(game, 3, _volcano(game.levels[3]), SEEN_BELOW + 1)
	return MapStates.of(game, clampi(level, 1, game.levels.size()))


## Shows the square around [param centre] on [param level] of [param game].
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
