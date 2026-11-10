class_name LevelReachedGoal
extends FlagGoal
## lib/domain/objective/goals/level_reached_goal.dart: the player has gone
## down to `level`: its map exists and the player either sees part of it (a
## descent reveals the landing area) or has units there.

var level: int


func _init(level_: int) -> void:
	level = level_


func is_met(game: Game, player: Player) -> bool:
	if game.map_for_level(level) == null:
		return false
	if not player.revealed_cells_on_level(level).is_empty():
		return true
	for unit: Unit in player.units_on_level(level).values():
		if unit.count > 0:
			return true
	return false
