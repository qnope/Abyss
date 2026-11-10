class_name ExploredAroundBaseGoal
extends FlagGoal
## lib/domain/objective/goals/explored_around_base_goal.dart: at least one
## exploration resolved on level 1: a revealed cell lies outside the area
## revealed around the base when the game started.
##
## Read from the revealed cells rather than the history, which forgets its
## oldest entries.


func is_met(game: Game, player: Player) -> bool:
	var map := game.map_for_level(1)
	if map == null:
		return false
	var start := GridPosition.keys(
		RevealAreaCalculator.around_base(player.base_x, player.base_y, map.width, map.height)
	)
	for cell: GridPosition in player.revealed_cells_on_level(1):
		if not start.has(cell.key()):
			return true
	return false
