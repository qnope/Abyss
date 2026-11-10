class_name BuildingLevelGoal
extends ObjectiveGoal
## lib/domain/objective/goals/building_level_goal.dart: the `type` building
## raised to `level`; each level counts one step.

var type: BuildingType.Value
var level: int


func _init(type_: BuildingType.Value, level_: int) -> void:
	type = type_
	level = level_


func progress_of(_game: Game, player: Player) -> ObjectiveProgress:
	return ObjectiveProgress.new(Building.level_in(player.buildings, type), level)
