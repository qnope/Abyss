extends TestCase
## test/domain/event/effects/caravan_effect_test.dart: the turtle caravan.
## The check of 'never drawn when the most abundant stock is under 100' on
## EventEffects.excludedAt waits for event_effects.dart, which waits for the
## predators (raid) and the survivors (volcano).

const ALGAE := ResourceType.Value.ALGAE
const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE

var _caravan := CaravanEffect.new()


## A player holding `algae`, `coral` and `ore`, and plenty of energy.
func _stocked(algae: int, coral: int, ore: int) -> Player:
	var player := EventSamples.event_player()
	var amounts: Dictionary[ResourceType.Value, int] = {
		ALGAE: algae, CORAL: coral, ORE: ore, ResourceType.Value.ENERGY: 900,
	}
	for type: ResourceType.Value in amounts:
		player.resources[type].amount = amounts[type]
	return player


## `player` once the caravan is drawn at the end of turn 11.
func _drawn(player: Player) -> Player:
	_caravan.on_draw(EventSamples.event_game(player, 11), player, 11, DartRandom.new(1))
	return player


func _amount(player: Player, type: ResourceType.Value) -> int:
	return player.resources[type].amount


func test_trades_the_most_abundant_of_algae_coral_and_ore_for_the_scarcest() -> void:
	var state := _drawn(_stocked(400, 120, 250)).event_state
	assert_eq(state.trade_from, ALGAE)
	assert_eq(state.trade_to, CORAL)


func test_ties_go_to_the_first_resource_in_the_usual_order() -> void:
	var first := _drawn(_stocked(200, 200, 50)).event_state
	assert_eq(first.trade_from, ALGAE)
	assert_eq(first.trade_to, ORE)
	var last := _drawn(_stocked(50, 300, 50)).event_state
	assert_eq(last.trade_from, CORAL)
	assert_eq(last.trade_to, ALGAE)


func test_never_drawn_when_the_most_abundant_stock_is_under_100() -> void:
	var poor := _stocked(99, 50, 20)
	assert_false(_caravan.allowed_at(EventSamples.event_game(poor), poor, 11))
	var enough := _stocked(100, 50, 20)
	assert_true(_caravan.allowed_at(EventSamples.event_game(enough), enough, 11))


func test_never_drawn_when_the_three_stocks_are_equal() -> void:
	var even := _stocked(300, 300, 300)
	assert_false(_caravan.allowed_at(EventSamples.event_game(even), even, 11))


func test_trading_gives_100_of_the_abundant_stock_for_70_of_the_scarce() -> void:
	var player := _drawn(_stocked(400, 120, 250))
	_caravan.apply(EventSamples.event_game(player, 12), player, true, 12)
	assert_eq(_amount(player, ALGAE), 300)
	assert_eq(_amount(player, CORAL), 190)
	assert_eq(_amount(player, ORE), 250)


func test_what_the_caravan_gives_stops_at_the_storage_cap() -> void:
	var player := _drawn(_stocked(400, 120, 250))
	player.resources[CORAL] = GameResource.new(CORAL, 120, 150)
	_caravan.apply(EventSamples.event_game(player, 12), player, true, 12)
	assert_eq(_amount(player, ALGAE), 300)
	assert_eq(_amount(player, CORAL), 150)


func test_turning_the_caravan_away_changes_nothing() -> void:
	var player := _drawn(_stocked(400, 120, 250))
	_caravan.apply(EventSamples.event_game(player, 12), player, false, 13)
	assert_eq(_amount(player, ALGAE), 400)
	assert_eq(_amount(player, CORAL), 120)


func test_trading_is_refused_once_the_stock_dropped_under_100() -> void:
	var player := _drawn(_stocked(400, 120, 250))
	var game := EventSamples.event_game(player, 12)
	assert_null(_caravan.refusal(game, player))
	player.resources[ALGAE].amount = 99
	assert_eq(_caravan.refusal(game, player), ActionFailure.Value.NOT_ENOUGH_STOCK_TO_TRADE)


func test_without_a_drawn_trade_there_is_nothing_to_refuse_nor_to_trade() -> void:
	var player := _stocked(400, 120, 250)
	var game := EventSamples.event_game(player, 12)
	assert_null(_caravan.refusal(game, player))
	_caravan.apply(game, player, true, 12)
	assert_eq(_amount(player, ALGAE), 400)


## Not in the Dart file: a stock the player lacks counts as none, and the
## draw leaves the dice alone.
func test_a_missing_stock_counts_as_none() -> void:
	var player := _stocked(400, 120, 250)
	player.resources.erase(CORAL)
	assert_eq(CaravanEffect.scarcest(player), CORAL)
	assert_eq(CaravanEffect.most_abundant(player), ALGAE)
	var random := DartRandom.new(1)
	_caravan.on_draw(EventSamples.event_game(player, 11), player, 11, random)
	assert_eq(random.next_int(1000), DartRandom.new(1).next_int(1000))
	assert_eq(CaravanEffect.TRADED, [ALGAE, CORAL, ORE])


## Not in the Dart file: a trade refused is not made.
func test_a_trade_refused_is_not_made() -> void:
	var player := _drawn(_stocked(400, 120, 250))
	player.resources[ALGAE].amount = 99
	_caravan.apply(EventSamples.event_game(player, 12), player, true, 12)
	assert_eq([_amount(player, ALGAE), _amount(player, CORAL)], [99, 120])
