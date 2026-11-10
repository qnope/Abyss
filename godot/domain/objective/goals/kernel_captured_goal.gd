class_name KernelCapturedGoal
extends FlagGoal
## lib/domain/objective/goals/kernel_captured_goal.dart: the volcanic kernel
## taken by the player, which opens its building.


func is_met(game: Game, player: Player) -> bool:
	return game.is_volcanic_kernel_captured_by(player.id)
