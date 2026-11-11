class_name ObjectiveCase
extends UiTestCase
## test/presentation/widgets/objective/objective_widget_helpers.dart: games on
## a given objective of the catalog, for the tests of the objectives' UI.


## [ObjectiveSamples.objective_game] whose player completed the first
## [param completed] objectives of the catalog.
func game_with_completed(completed: int) -> Game:
	var game := ObjectiveSamples.objective_game()
	var done: Array[ObjectiveId.Value] = []
	for objective: Objective in ObjectiveCatalog.all().slice(0, completed):
		done.append(objective.id)
	game.human_player().saved_objective_state = ObjectiveState.new(done)
	return game


## Lays a wreck on the map of [param game] to search until [param until].
func lay_wreck(game: Game, until := 17) -> void:
	var events := game.human_player().event_state
	events.wreck_position = GridPosition.new(6, 6)
	events.wreck_until_turn = until


## A game whose player is on the objective [param id]: those before it done.
func game_on(id: ObjectiveId.Value) -> Game:
	var index := 0
	for objective in ObjectiveCatalog.all():
		if objective.id == id:
			break
		index += 1
	return game_with_completed(index)
