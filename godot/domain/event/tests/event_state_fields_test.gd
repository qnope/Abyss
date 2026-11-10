extends TestCase
## Not in the Dart file (test/domain/event/event_state_test.dart): what the
## Dart tests of the resolvers hold of EventState, here before them. The
## fields a constructor takes, an effect that is none, the predators and
## the wreck a state forgets.

const Type := RandomEventType.Value


func test_takes_its_fields_in_the_dart_order() -> void:
	var wave := MonsterLair.new(MonsterDifficulty.Value.EASY, 8)
	var wreck := GridPosition.new(3, 4)
	var state := EventState.new(
		13, Type.CARAVAN, 7, Type.STORM, Type.COLD_CURRENT, 9, true, 5, 4,
		ResourceType.Value.CORAL, ResourceType.Value.ALGAE, wave, 11, wreck, 15,
	)
	assert_eq(
		[state.next_draw_turn, state.pending, state.pending_turn, state.last_drawn],
		[13, Type.CARAVAN, 7, Type.STORM],
	)
	assert_eq([state.active, state.active_until_turn], [Type.COLD_CURRENT, 9])
	assert_eq([state.heating, state.events_seen, state.survivors], [true, 5, 4])
	assert_eq(
		[state.trade_from, state.trade_to],
		[ResourceType.Value.CORAL, ResourceType.Value.ALGAE],
	)
	assert_eq([state.predator_wave, state.predators_turn], [wave, 11])
	assert_eq([state.wreck_position, state.wreck_until_turn], [wreck, 15])


func test_a_pending_event_without_its_turn_is_not_pending() -> void:
	assert_false(EventState.new(null, Type.CARAVAN).has_pending())
	assert_false(EventState.new(null, null, 7).has_pending())


func test_an_effect_without_a_last_turn_is_not_active() -> void:
	var state := EventState.new(null, null, null, null, Type.STORM)
	assert_false(state.is_active(Type.STORM, 1))


## The first value of the enum is 0, which null must not equal.
func test_no_effect_is_not_the_first_event() -> void:
	assert_false(EventState.new().is_active(Type.WARM_CURRENT, 1))


func test_clear_predators_forgets_the_wave_and_its_turn() -> void:
	var state := EventState.new()
	state.predator_wave = MonsterLair.new(MonsterDifficulty.Value.EASY, 8)
	state.predators_turn = 6
	state.clear_predators()
	assert_null(state.predator_wave)
	assert_null(state.predators_turn)


func test_a_wreck_is_searched_once_gone_until_the_turn_ends() -> void:
	var state := EventState.new()
	assert_false(state.wreck_searched())
	state.wreck_position = GridPosition.new(3, 4)
	state.wreck_until_turn = 9
	assert_false(state.wreck_searched())
	state.wreck_position = null
	assert_true(state.wreck_searched())
	state.clear_wreck()
	assert_false(state.wreck_searched())
	assert_null(state.wreck_until_turn)
