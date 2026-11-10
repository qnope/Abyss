class_name CurrentObjective
extends RefCounted
## lib/domain/objective/current_objective.dart: the objective a player is
## on, read without computing any progress.


## The first objective of the catalog `player` has not completed in `game`,
## null once all are.
static func of(game: Game, player: Player) -> Objective:
	var completed: Dictionary[ObjectiveId.Value, bool] = {}
	for id: ObjectiveId.Value in ObjectiveMigration.state_of(game, player).completed:
		completed[id] = true
	return ObjectiveCatalog.first_not_done(completed)
