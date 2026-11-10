class_name UnitCountGoal
extends ObjectiveGoal
## lib/domain/objective/goals/unit_count_goal.dart: `count` units of `type`
## owned, all levels together; each unit counts one step.

var type: UnitType.Value
var count: int


func _init(type_: UnitType.Value, count_: int) -> void:
	type = type_
	count = count_


func progress_of(_game: Game, player: Player) -> ObjectiveProgress:
	var owned := 0
	for level: int in player.units_per_level:
		var units: Dictionary[UnitType.Value, Unit] = player.units_per_level[level]
		var unit: Unit = units.get(type)
		owned += unit.count if unit != null else 0
	return ObjectiveProgress.new(owned, count)
