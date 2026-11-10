class_name ResearchStartedGoal
extends FlagGoal
## lib/domain/objective/goals/research_started_goal.dart: at least one
## research node done, in any branch.


func is_met(_game: Game, player: Player) -> bool:
	for branch: TechBranchState in player.tech_branches.values():
		if branch.research_level >= 1:
			return true
	return false
