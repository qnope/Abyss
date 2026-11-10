extends TestCase
## test/domain/action/choose_event_refusal_test.dart: a caravan refused for
## want of the stock to trade.

const ALGAE := ResourceType.Value.ALGAE
const CORAL := ResourceType.Value.CORAL
const CARAVAN := RandomEventType.Value.CARAVAN


## Caravan drawn at the end of turn 11 that trades algae for coral, once the
## algae dropped to `algae` during turn 12.
func _caravan(algae: int) -> Game:
	var player := EventSamples.event_player()
	player.resources[ALGAE].amount = 400
	player.resources[CORAL].amount = 120
	player.resources[ResourceType.Value.ORE].amount = 250
	var game := EventSamples.event_game(player, 12)
	EventEffects.on_draw(game, player, CARAVAN, 11, DartRandom.new(1))
	player.event_state.set_pending(CARAVAN, 12)
	player.resources[ALGAE].amount = algae
	return game


func _choose(game: Game, accept: bool) -> ActionResult:
	return ActionExecutor.new().execute(ChooseEventAction.new(accept), game, game.human_player())


func test_trading_fails_when_the_stock_to_give_dropped_under_100() -> void:
	var game := _caravan(60)
	var player := game.human_player()
	var result := _choose(game, true)
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.NOT_ENOUGH_STOCK_TO_TRADE)
	assert_true(player.event_state.has_pending())
	assert_eq(player.event_state.trade_from, ALGAE)
	assert_eq(player.resources[ALGAE].amount, 60)


func test_turning_the_caravan_away_still_works_without_the_stock() -> void:
	var game := _caravan(60)
	var player := game.human_player()
	assert_true(_choose(game, false).is_success)
	assert_false(player.event_state.has_pending())
	assert_null(player.event_state.trade_from)
	assert_null(player.event_state.trade_to)


func test_trading_with_the_stock_settles_the_caravan() -> void:
	var game := _caravan(100)
	var player := game.human_player()
	assert_true(_choose(game, true).is_success)
	assert_eq(player.resources[ALGAE].amount, 0)
	assert_eq(player.resources[CORAL].amount, 190)
	assert_null(player.event_state.trade_from)


## Not in the Dart file: the result names the event settled.
func test_the_result_names_the_event_settled() -> void:
	var game := _caravan(100)
	var result: ChooseEventResult = _choose(game, true)
	assert_eq([result.is_success, result.reason, result.event], [true, null, CARAVAN])
	assert_eq(ChooseEventResult.success().event, RandomEventType.Value.SURVIVORS)
