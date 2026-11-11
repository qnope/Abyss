extends TestCase
## test/domain/script/strategies/event_moves_choice_test.dart: the choice a
## script makes on each random event.

const Type := RandomEventType.Value
const ROOM := NoiseRules.THRESHOLD - EventRules.EFFECT_TURNS * EventRules.WARM_NOISE_PER_TURN

var _planner := ArmyPlanner.new()


func _raid() -> MonsterLair:
	return MonsterLair.new(MonsterDifficulty.Value.EASY, 3, MonsterFamily.Value.SWARM)


func _warm(noise := 0, raid := false) -> Variant:
	var player := EventSamples.event_player()
	player.raid_state.noise = noise
	if raid:
		player.raid_state.announce(_raid(), 13)
	EventMoves.choose_event(EventMoveSamples.choice_turn(player, Type.WARM_CURRENT), _planner)
	return EventMoveSamples.choice_of(player)


func test_warm_current_exploited_while_three_turns_of_noise_stay_under_the_threshold() -> void:
	assert_eq(_warm(ROOM - 1), true)


func test_warm_current_let_pass_when_they_would_reach_it_or_a_raid_is_announced() -> void:
	assert_eq(_warm(ROOM), false)
	assert_eq(_warm(0, true), false)


func test_predators_fought_when_the_defenders_and_the_rampart_beat_them() -> void:
	var player := EventSamples.threatened_player({UnitType.Value.GUARDIAN: 30, UnitType.Value.HARPOONIST: 30}, 3)
	EventMoves.choose_event(EventMoveSamples.choice_turn(player, Type.PREDATORS), _planner)
	assert_eq(EventMoveSamples.choice_of(player), true)
	assert_eq(player.event_state.predators_turn, 12)


func test_predators_baited_when_the_base_has_no_one_to_beat_them() -> void:
	var player := EventSamples.threatened_player()
	EventMoves.choose_event(EventMoveSamples.choice_turn(player, Type.PREDATORS), _planner)
	assert_eq(EventMoveSamples.choice_of(player), false)
	assert_eq(player.resources[ResourceType.Value.ALGAE].amount, 700)


func _survivors(guardians := 0) -> Variant:
	var player := EventSamples.producing_player()
	player.units_on_level(1)[UnitType.Value.GUARDIAN].count = guardians
	var turn := EventMoveSamples.choice_turn(player, Type.SURVIVORS)
	player.event_state.survivors = 3
	assert_eq(RecruitMoves.algae_margin(turn) >= 6, guardians == 0)
	EventMoves.choose_event(turn, _planner)
	return EventMoveSamples.choice_of(player)


func test_survivors_welcomed_when_the_algae_margin_feeds_them() -> void:
	assert_eq(_survivors(), true)


func test_survivors_refused_when_the_base_already_eats_its_algae() -> void:
	assert_eq(_survivors(100), false)


func _caravan(coral: int, ore: int) -> Variant:
	var player := RaidSamples.raid_player()
	player.resources[ResourceType.Value.CORAL].amount = coral
	player.resources[ResourceType.Value.ORE].amount = ore
	var turn := EventMoveSamples.choice_turn(player, Type.CARAVAN)
	player.event_state.trade_from = ResourceType.Value.CORAL
	player.event_state.trade_to = ResourceType.Value.ORE
	EventMoves.choose_event(turn, _planner)
	return EventMoveSamples.choice_of(player)


func test_caravan_traded_when_the_stock_given_is_twice_the_stock_received() -> void:
	assert_eq(_caravan(400, 200), true)


func test_caravan_refused_below_twice_or_when_the_stock_cannot_pay() -> void:
	assert_eq(_caravan(399, 200), false)
	assert_eq(_caravan(90, 0), false)


func test_chooses_nothing_on_another_turn_than_the_one_of_the_choice() -> void:
	var player := EventSamples.event_player()
	var turn := EventMoveSamples.choice_turn(player, Type.WARM_CURRENT)
	turn.game.turn = 13
	EventMoves.choose_event(turn, _planner)
	assert_null(EventMoveSamples.choice_of(player))
	assert_true(player.event_state.has_pending())


func test_storms_and_wrecks_are_never_taken_as_an_offer() -> void:
	var turn := EventMoveSamples.script_turn_of(EventSamples.event_game(EventSamples.event_player()))
	assert_false(EventMoves.wants_event(turn, Type.STORM, _planner))
	assert_false(EventMoves.wants_event(turn, Type.WRECK, _planner))


## Not in the Dart file: no wave of predators, no trade, no survivors told,
## and a replay that keeps its own choice.
func test_what_an_event_lacks_is_never_taken_and_a_replay_does_not_choose() -> void:
	var turn := EventMoveSamples.script_turn_of(EventSamples.event_game(EventSamples.producing_player()))
	assert_false(EventMoves.wants_event(turn, Type.PREDATORS, _planner))
	assert_false(EventMoves.wants_event(turn, Type.CARAVAN, _planner))
	turn.player.event_state.trade_from = ResourceType.Value.CORAL
	assert_false(EventMoves.wants_event(turn, Type.CARAVAN, _planner))
	assert_true(EventMoves.wants_event(turn, Type.SURVIVORS, _planner))
	var player := EventSamples.event_player()
	var replay := EventMoveSamples.choice_turn(player, Type.WARM_CURRENT)
	EventMoves.play_events(replay, _planner, false)
	assert_null(EventMoveSamples.choice_of(player))
	EventMoves.play_events(replay, _planner)
	assert_eq(EventMoveSamples.choice_of(player), true)
