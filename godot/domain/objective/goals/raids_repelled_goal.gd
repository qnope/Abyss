class_name RaidsRepelledGoal
extends ObjectiveGoal
## lib/domain/objective/goals/raids_repelled_goal.dart: `count` raids pushed
## back since the start of the game.

var count: int


func _init(count_: int) -> void:
	count = count_


func progress_of(_game: Game, player: Player) -> ObjectiveProgress:
	return ObjectiveProgress.new(player.raid_state.raids_repelled, count)
