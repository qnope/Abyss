@abstract
class_name FlagGoal
extends ObjectiveGoal
## `FlagGoal` of lib/domain/objective/objective_goal.dart: a goal met or
## not, in one step.


@abstract func is_met(game: Game, player: Player) -> bool


func progress_of(game: Game, player: Player) -> ObjectiveProgress:
	return ObjectiveProgress.flag(is_met(game, player))
