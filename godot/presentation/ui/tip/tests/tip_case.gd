class_name TipCase
extends UiTestCase
## The base of the tests of the tips: a game whose player has the noise gauge
## and a storm to read about (test/helpers: the situations of tip_catalog_test),
## and the actions that save what is seen.

const Id := TipId.Value

var game: Game
var actions: GameActions


func before_each() -> void:
	game = ObjectiveSamples.objective_game()
	game.human_player().saved_objective_state = ObjectiveState.new([], false, true)
	actions = GameActions.new(game)


## The noise gauge and the storm tips are waiting.
func lay_noise_and_storm() -> void:
	game.human_player().event_state.record_draw(RandomEventType.Value.STORM)
	game.human_player().raid_state.add_noise(DartMath.trunc_div(NoiseRules.THRESHOLD, 4))


func state() -> ObjectiveState:
	return game.human_player().saved_objective_state


func tip(id: TipId.Value) -> Tip:
	return TipCatalog.by_id(id)
