extends TestCase
## test/domain/action/spy_base/spy_base_test.dart: a Scout sent to the
## base of another player, bringing back a report of it.

const SCOUT := UnitType.Value.SCOUT
const GUARDIAN := UnitType.Value.GUARDIAN
const HARPOONIST := UnitType.Value.HARPOONIST


func _scene(scout := true) -> Game:
	var game := AssaultSamples.assault_game()
	var scouts: Dictionary[UnitType.Value, int] = {}
	if scout:
		scouts[SCOUT] = 2
	AssaultSamples.station(game.human_player(), scouts)
	var rival := AssaultSamples.rival_of(game)
	AssaultSamples.station(rival, {GUARDIAN: 7, HARPOONIST: 12})
	AssaultSamples.set_level(rival, BuildingType.Value.CORAL_CITADEL, 3)
	rival.resources[ResourceType.Value.CORAL].amount = 640
	return game


func _spy(game: Game) -> ActionResult:
	return SpyBaseAction.new(AssaultSamples.rival_of(game).id).execute(game, game.human_player())


func _intel(game: Game) -> BaseIntel:
	return game.human_player().intel()[AssaultSamples.rival_of(game).id]


func test_spying_a_base_writes_down_its_headquarters_rampart_army_and_stocks() -> void:
	var game := _scene()
	game.turn = 12
	assert_true(_spy(game).is_success)
	var intel := _intel(game)
	assert_eq([intel.turn, intel.headquarters_level, intel.rampart_level], [12, 5, 3])
	assert_eq(intel.army, {GUARDIAN: 7, HARPOONIST: 12})
	assert_eq(intel.stocks[ResourceType.Value.CORAL], 640)


func test_spying_a_base_costs_the_scout_that_went() -> void:
	var game := _scene()
	_spy(game)
	assert_eq(AssaultSamples.standing(game.human_player(), SCOUT), 1)


func test_spying_a_base_leaves_the_target_as_it_was() -> void:
	var game := _scene()
	_spy(game)
	var rival := AssaultSamples.rival_of(game)
	assert_eq(AssaultSamples.standing(rival, GUARDIAN), 7)
	assert_true(rival.intel().is_empty())
	assert_true(rival.history_entries.is_empty())


func test_spying_a_base_is_a_snapshot_the_base_can_change_afterwards() -> void:
	var game := _scene()
	_spy(game)
	AssaultSamples.station(AssaultSamples.rival_of(game), {})
	assert_eq(_intel(game).army[GUARDIAN], 7)


func test_spying_a_base_holds_for_five_turns_then_goes_stale() -> void:
	var game := _scene()
	game.turn = 12
	_spy(game)
	var intel := _intel(game)
	assert_eq([intel.is_fresh(12), intel.is_fresh(17), intel.is_fresh(18)], [true, true, false])
	assert_eq(intel.turns_left(14), 3)


func test_spying_a_base_a_second_spy_renews_the_report() -> void:
	var game := _scene()
	game.turn = 12
	_spy(game)
	game.turn = 16
	AssaultSamples.station(AssaultSamples.rival_of(game), {GUARDIAN: 2})
	AssaultSamples.station(game.human_player(), {SCOUT: 1})
	_spy(game)
	var intel := _intel(game)
	assert_eq(intel.turn, 16)
	assert_eq(intel.army, {GUARDIAN: 2})


func test_the_human_can_be_named_as_a_target_for_a_script() -> void:
	var game := _scene()
	var rival := AssaultSamples.rival_of(game)
	var human := game.human_player()
	AssaultSamples.station(rival, {SCOUT: 1})
	rival.add_revealed_cell(1, GridPosition.new(human.base_x, human.base_y))
	var result := SpyBaseAction.new(SpyBaseAction.HUMAN).execute(game, rival)
	assert_true(result.is_success)
	assert_not_null(rival.intel().get(human.id))
