extends TestCase
## test/domain/resource/resource_credit_test.dart: gains added to a stock,
## each capped by its storage.

const ALGAE := ResourceType.Value.ALGAE
const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE


func _resources() -> Dictionary[ResourceType.Value, GameResource]:
	return {CORAL: GameResource.new(CORAL, 90, 100), ORE: GameResource.new(ORE, 10)}


func test_adds_each_amount_and_returns_what_was_added() -> void:
	var stock := _resources()
	var added := ResourceCredit.add(stock, {ORE: 20})
	assert_eq(stock[ORE].amount, 30)
	assert_eq(added, {ORE: 20})


func test_stops_at_the_storage_cap_and_reports_only_what_fitted() -> void:
	var stock := _resources()
	var added := ResourceCredit.add(stock, {CORAL: 30})
	assert_eq(stock[CORAL].amount, 100)
	assert_eq(added, {CORAL: 10})


func test_a_resource_the_player_lacks_adds_nothing() -> void:
	var added := ResourceCredit.add(_resources(), {ALGAE: 5})
	assert_eq(added, {ALGAE: 0})


## Not in the Dart file: `added` follows the order of the amounts, as a Dart
## map does.
func test_reports_in_the_order_of_the_amounts() -> void:
	var added := ResourceCredit.add(_resources(), {ORE: 1, ALGAE: 5, CORAL: 2})
	assert_eq(added.keys(), [ORE, ALGAE, CORAL])
