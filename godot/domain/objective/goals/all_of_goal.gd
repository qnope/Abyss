class_name AllOfGoal
extends ObjectiveGoal
## lib/domain/objective/goals/all_of_goal.dart: every one of `goals`; their
## steps add up.

var goals: Array[ObjectiveGoal]


func _init(goals_: Array[ObjectiveGoal]) -> void:
	goals = goals_


## The progresses of `goals` summed. None, where Dart's `reduce` throws, logs
## an error and gives 0/0.
func progress_of(game: Game, player: Player) -> ObjectiveProgress:
	if goals.is_empty():
		push_error("AllOfGoal.progress_of: no goal")
		return ObjectiveProgress.new(0, 0)
	var total := goals[0].progress_of(game, player)
	for index: int in range(1, goals.size()):
		total = total.plus(goals[index].progress_of(game, player))
	return total
