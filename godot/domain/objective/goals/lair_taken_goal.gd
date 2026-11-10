class_name LairTakenGoal
extends FlagGoal
## lib/domain/objective/goals/lair_taken_goal.dart: at least one monster lair
## beaten by the player, on any level: a won fight marks the lair's cell as
## collected by the winner.


func is_met(game: Game, player: Player) -> bool:
	for map: GameMap in game.levels.values():
		for cell: MapCell in map.cells:
			if cell.content == CellContentType.Value.MONSTER_LAIR and cell.collected_by == player.id:
				return true
	return false
