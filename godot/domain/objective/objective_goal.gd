@abstract
class_name ObjectiveGoal
extends RefCounted
## lib/domain/objective/objective_goal.dart: a condition on the state of a
## game that an objective asks a player to reach. Pure: it reads the game,
## never changes it. Its second type, FlagGoal, is flag_goal.gd.


@abstract func progress_of(game: Game, player: Player) -> ObjectiveProgress
