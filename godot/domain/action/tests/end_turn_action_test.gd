extends TestCase
## test/domain/action/end_turn_action_test.dart: the end of a turn as an
## action, and the TurnEndEntry it leaves.

var executor: ActionExecutor


func before_each() -> void:
	super()
	executor = ActionExecutor.new()


## `_scenario`: a player of the defaults, with the `buildings`, `resources`
## and level-1 `units` given on top, and its game of `turn`.
static func _scenario(
	buildings: Dictionary[BuildingType.Value, Building] = {},
	resources: Dictionary[ResourceType.Value, GameResource] = {},
	units: Dictionary[UnitType.Value, Unit] = {},
	turn := 5,
) -> Game:
	var r := PlayerDefaults.resources()
	r.merge(resources, true)
	var b := PlayerDefaults.buildings()
	b.merge(buildings, true)
	var u: Dictionary[UnitType.Value, Unit] = PlayerDefaults.units_per_level()[1]
	u.merge(units, true)
	var per_level: Dictionary[int, Dictionary] = {1: u}
	var player := Player.new("Nemo", null, 0, 0, r, b, null, per_level)
	var game := Game.single_player(player)
	game.turn = turn
	return game


static func _farm() -> Dictionary[BuildingType.Value, Building]:
	return {BuildingType.Value.ALGAE_FARM: Building.new(BuildingType.Value.ALGAE_FARM, 1)}


func test_exposes_action_type_end_turn_and_french_description() -> void:
	var action := EndTurnAction.new()
	assert_eq(action.type(), ActionType.Value.END_TURN)
	assert_eq(action.description(), "Terminer le tour")


func test_validate_always_succeeds() -> void:
	var game := _scenario()
	assert_true(EndTurnAction.new().validate(game, game.human_player()).is_success)


func test_execute_advances_the_turn_and_returns_a_turn_result() -> void:
	var game := _scenario({}, {}, {}, 5)

	var result := executor.execute(EndTurnAction.new(), game, game.human_player())

	assert_true(result is EndTurnActionResult)
	var etr: EndTurnActionResult = result
	assert_true(etr.is_success)
	assert_not_null(etr.turn_result)
	assert_eq(etr.turn_result.previous_turn, 5)
	assert_eq(etr.turn_result.new_turn, 6)
	assert_eq(game.turn, 6)


func test_executor_appends_a_turn_end_entry_on_success() -> void:
	var game := _scenario(_farm(), {}, {}, 3)
	var player := game.human_player()

	executor.execute(EndTurnAction.new(), game, player)

	assert_eq(player.history_entries.size(), 1)
	assert_true(player.history_entries.back() is TurnEndEntry)


func test_turn_end_entry_turn_is_the_turn_that_ended_not_the_new_turn() -> void:
	var game := _scenario({}, {}, {}, 7)
	var player := game.human_player()

	executor.execute(EndTurnAction.new(), game, player)

	var entry: TurnEndEntry = player.history_entries.back()
	assert_eq(entry.turn, 7)
	assert_eq(game.turn, 8)


func test_turn_end_entry_carries_changes_deactivated_buildings_and_lost_units() -> void:
	var game := _scenario(_farm(), {}, {UnitType.Value.SCOUT: Unit.new(UnitType.Value.SCOUT, 5)}, 2)
	var player := game.human_player()

	var result: EndTurnActionResult = executor.execute(EndTurnAction.new(), game, player)
	var tr := result.turn_result
	var entry: TurnEndEntry = player.history_entries.back()

	assert_eq(entry.changes, tr.changes)
	assert_eq(entry.deactivated_buildings, tr.deactivated_buildings)
	assert_eq(entry.lost_units, tr.lost_units)


## Not in the Dart file: a result of another type, or without a turn
## result, leaves no entry.
func test_no_entry_without_a_turn_result() -> void:
	var game := _scenario()
	var action := EndTurnAction.new()
	var player := game.human_player()
	assert_null(action.make_history_entry(game, player, ActionResult.success(), 5))
	assert_null(action.make_history_entry(game, player, EndTurnActionResult.success(), 5))


## Not in the Dart file: the dice and the factions as given.
func test_keeps_its_dice_and_whether_the_factions_play() -> void:
	var dice := DartRandom.new(5)
	var action := EndTurnAction.new(dice, false)
	assert_eq(action.random, dice)
	assert_false(action.play_factions)
	assert_true(EndTurnAction.new().play_factions)
	assert_null(EndTurnAction.new().random)
