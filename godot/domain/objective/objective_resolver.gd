class_name ObjectiveResolver
extends RefCounted
## lib/domain/objective/objective_resolver.dart: completes, at the end of a
## turn, the objectives a player has reached, and credits their rewards.


## Every objective of the catalog not yet completed by `player` whose goal
## is met in `game`, in catalog order; each reward is credited up to the
## storage. A completion is never undone nor paid twice.
static func resolve(game: Game, player: Player) -> Array[ObjectiveCompletion]:
	var state := ObjectiveMigration.state_of(game, player)
	var completions: Array[ObjectiveCompletion] = []
	for objective: Objective in ObjectiveCatalog.all():
		if state.is_completed(objective.id):
			continue
		if not objective.is_done(game, player):
			continue
		state.complete(objective.id)
		var credited := ResourceCredit.add(player.resources, objective.reward)
		completions.append(ObjectiveCompletion.new(objective, credited))
	return completions
