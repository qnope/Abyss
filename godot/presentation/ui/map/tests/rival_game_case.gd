class_name RivalGameCase
extends MapSheetCase
## The map's tests that need a rival: a faction of the game, whose base stands
## at (8, 8) of the first level.

const RIVAL := FactionPersonality.Value.PEARL_ORDER
const RIVAL_BASE := Vector2i(8, 8)

var rival: Faction


## A game against [constant RIVAL], with [param overrides] on the map.
func start_with_rival(overrides: Dictionary[Vector2i, MapCell] = {}) -> void:
	start(overrides)
	rival = Faction.new(RIVAL)
	game.players[rival.id()] = Player.new(rival.name(), rival.id(), RIVAL_BASE.x, RIVAL_BASE.y)
	var drawn: Array[FactionPersonality.Value] = [RIVAL]
	game.saved_factions = drawn
