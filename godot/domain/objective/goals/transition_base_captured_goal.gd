class_name TransitionBaseCapturedGoal
extends FlagGoal
## lib/domain/objective/goals/transition_base_captured_goal.dart: the
## transition base of `type` captured by the player.

var type: TransitionBaseType.Value


func _init(type_: TransitionBaseType.Value) -> void:
	type = type_


func is_met(game: Game, player: Player) -> bool:
	return game.captured_base_types_of(player.id).has(type)
