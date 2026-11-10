class_name Objective
extends RefCounted
## lib/domain/objective/objective.dart: one step of the main thread: what to
## reach, and what it pays. The presentation words it after its `id` and its
## `goal`.

var id: ObjectiveId.Value
var chapter: ObjectiveChapter.Value
## Resources credited once the objective is reached; a read-only constant
## of ObjectiveRewards.
var reward: Dictionary[ResourceType.Value, int]
var goal: ObjectiveGoal


func _init(
	id_: ObjectiveId.Value,
	chapter_: ObjectiveChapter.Value,
	reward_: Dictionary[ResourceType.Value, int],
	goal_: ObjectiveGoal,
) -> void:
	id = id_
	chapter = chapter_
	reward = reward_
	goal = goal_


## Where `player` stands on this objective in `game`.
func progress_of(game: Game, player: Player) -> ObjectiveProgress:
	return goal.progress_of(game, player)


func is_done(game: Game, player: Player) -> bool:
	return progress_of(game, player).is_done()
