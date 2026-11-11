class_name CellRoute
extends RefCounted
## Where a touch on a cell of the map leads (lib/presentation/screens/game/
## game_screen_map_actions.dart, `_showCellAction`), without opening anything:
## the kind of the cell and the cell to act on. A touch on any cell of the
## volcano acts on its anchor; a hidden cell is explored where it was touched.
##
## The kinds with a sheet of their own that another lot builds (a lair, a post,
## the volcano, a rival's base) are told by their kind, for [CellRouter] to hand
## to whoever registered for it.

enum Kind {
	## A cell not seen: a scout can be sent.
	EXPLORE,
	## A cell already emptied by the human, or by a faction.
	VISITED, TAKEN,
	## The player's own base.
	HOME,
	## A treasure, ruins or a wreck to search.
	TREASURE,
	## The arrival of a passage from the level above.
	PASSAGE,
	## Nothing to see.
	PLAIN,
	## The lairs, the posts, the volcano and the rival bases.
	LAIR, POST, KERNEL, FACTION_BASE,
}

var kind: Kind
var level: int
var x: int
var y: int
var cell: MapCell
## The faction that emptied the cell, for [constant Kind.TAKEN].
var rival: Faction


func _init(kind_: Kind, level_: int, x_: int, y_: int, cell_: MapCell, rival_: Faction = null) -> void:
	kind = kind_
	level = level_
	x = x_
	y = y_
	cell = cell_
	rival = rival_


## The route of a touch on the cell ([param tap_x], [param tap_y]) of
## [param level] in [param game].
static func of(game: Game, level: int, tap_x: int, tap_y: int) -> CellRoute:
	var human := game.human_player()
	var map: GameMap = game.levels[level]
	var target := VolcanoFootprint.tap_target(map, human.revealed_cells_set_on_level(level), tap_x, tap_y)
	if not target.is_revealed:
		return CellRoute.new(Kind.EXPLORE, level, tap_x, tap_y, map.cell_at(tap_x, tap_y))
	var x := target.position.x
	var y := target.position.y
	var cell := map.cell_at(x, y)
	if cell.is_collected() and cell.content != CellContentType.Value.VOLCANIC_KERNEL:
		var rival := RivalTaker.of(game, cell)
		return CellRoute.new(Kind.VISITED if rival == null else Kind.TAKEN, level, x, y, cell, rival)
	if level == 1 and x == human.base_x and y == human.base_y:
		return CellRoute.new(Kind.HOME, level, x, y, cell)
	if level == 1 and _faction_base_at(game, x, y):
		return CellRoute.new(Kind.FACTION_BASE, level, x, y, cell)
	return CellRoute.new(_kind_of(cell), level, x, y, cell)


## Whether the base of a faction stands on the cell ([param x], [param y]).
static func _faction_base_at(game: Game, x: int, y: int) -> bool:
	for faction in game.factions():
		var player: Player = game.players.get(faction.id())
		if player != null and player.base_x == x and player.base_y == y:
			return true
	return false


static func _kind_of(cell: MapCell) -> Kind:
	match cell.content:
		CellContentType.Value.RESOURCE_BONUS, CellContentType.Value.RUINS, CellContentType.Value.WRECK:
			return Kind.TREASURE
		CellContentType.Value.MONSTER_LAIR:
			return Kind.LAIR if cell.lair != null else Kind.PLAIN
		CellContentType.Value.TRANSITION_BASE:
			return Kind.POST if cell.transition_base != null else Kind.PLAIN
		CellContentType.Value.PASSAGE:
			return Kind.PASSAGE
		CellContentType.Value.VOLCANIC_KERNEL:
			return Kind.KERNEL
	return Kind.PLAIN
