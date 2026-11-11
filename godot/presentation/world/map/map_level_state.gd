class_name MapLevelState
extends RefCounted
## What the map of one level shows, read from the game by `app/` (the
## parameters of Flutter's `GameMapView`): the grid, the cells the player has
## seen, the player's base (the first level only), the scouts on their way, the
## rival bases and the volcano's owners with their colours, and who holds the
## post above each passage. This layer reads the domain but never the
## interface's palette or a faction's colour: `app/` gives them.

var level: int
var map: GameMap
## The id of the human player, whose posts are the player's.
var human_id: String
## The cells seen, by key (Vector2i): the volcano is seen whole as soon as one
## of its cells is, which [MapLooks] adds.
var revealed: Dictionary[Vector2i, bool]
## The cell of the player's base, a Vector2i, or null away from the first level.
var base: Variant = null
## The scouts sent and not yet back: each target cell with the cell its scout
## set off from.
var pending: Dictionary[Vector2i, Vector2i] = {}
## The colour of each rival base of the level, by cell.
var faction_bases: Dictionary[Vector2i, Color] = {}
## The seal colour of each player who can hold the volcano, by player id.
var owner_colors: Dictionary[String, Color] = {}
## Who holds the post above each passage of the level, by cell.
var passage_holders: Dictionary[Vector2i, PostHolder.Value] = {}


func _init(
	level_: int, map_: GameMap, human_id_: String, revealed_: Dictionary[Vector2i, bool] = {}
) -> void:
	level = level_
	map = map_
	human_id = human_id_
	revealed = revealed_
