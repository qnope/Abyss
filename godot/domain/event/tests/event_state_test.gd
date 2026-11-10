extends TestCase
## test/domain/event/event_state_test.dart: the bookkeeping of the random
## events of a player.

const Type := RandomEventType.Value


func test_a_new_state_has_nothing_scheduled_pending_or_active() -> void:
	var state := EventState.new()
	assert_null(state.next_draw_turn)
	assert_false(state.has_pending())
	assert_null(state.last_drawn)
	assert_null(state.active)
	assert_false(state.heating)
	assert_eq(state.events_seen, 0)


func test_schedule_sets_the_turn_of_the_next_draw() -> void:
	var state := EventState.new()
	state.schedule(13)
	assert_eq(state.next_draw_turn, 13)


func test_set_pending_waits_for_a_choice_and_remembers_the_draw() -> void:
	var state := EventState.new()
	state.set_pending(Type.WRECK, 7)
	assert_true(state.has_pending())
	assert_eq(state.pending, Type.WRECK)
	assert_eq(state.pending_turn, 7)
	assert_eq(state.last_drawn, Type.WRECK)
	assert_eq(state.events_seen, 1)


func test_record_draw_remembers_a_draw_that_waits_for_no_choice() -> void:
	var state := EventState.new()
	state.record_draw(Type.STORM)
	assert_false(state.has_pending())
	assert_eq(state.last_drawn, Type.STORM)
	assert_eq(state.events_seen, 1)


func test_clear_pending_forgets_the_choice_but_keeps_the_last_draw() -> void:
	var state := EventState.new()
	state.set_pending(Type.CARAVAN, 7)
	state.clear_pending()
	assert_false(state.has_pending())
	assert_null(state.pending)
	assert_null(state.pending_turn)
	assert_eq(state.last_drawn, Type.CARAVAN)


func test_a_new_state_holds_no_offer() -> void:
	var state := EventState.new()
	assert_null(state.survivors)
	assert_null(state.trade_from)
	assert_null(state.trade_to)


func test_clear_pending_forgets_the_offer_of_the_settled_event() -> void:
	var state := EventState.new()
	state.set_pending(Type.CARAVAN, 7)
	state.survivors = 4
	state.trade_from = ResourceType.Value.CORAL
	state.trade_to = ResourceType.Value.ALGAE
	state.clear_pending()
	assert_null(state.survivors)
	assert_null(state.trade_from)
	assert_null(state.trade_to)


func test_an_activated_effect_lasts_through_its_last_turn_inclusive() -> void:
	var state := EventState.new()
	state.activate(Type.WARM_CURRENT, 9)
	assert_true(state.is_active(Type.WARM_CURRENT, 7))
	assert_true(state.is_active(Type.WARM_CURRENT, 9))
	assert_false(state.is_active(Type.WARM_CURRENT, 10))
	assert_false(state.is_active(Type.STORM, 8))


func test_activate_resets_the_heating_of_a_previous_cold_current() -> void:
	var state := EventState.new()
	state.activate(Type.COLD_CURRENT, 9)
	state.heating = true
	state.activate(Type.STORM, 12)
	assert_false(state.heating)


func test_expire_effects_keeps_the_effect_up_to_its_last_turn() -> void:
	var state := EventState.new()
	state.activate(Type.COLD_CURRENT, 9)
	state.heating = true
	state.expire_effects(9)
	assert_eq(state.active, Type.COLD_CURRENT)
	assert_true(state.heating)


func test_expire_effects_clears_the_effect_after_its_last_turn() -> void:
	var state := EventState.new()
	state.activate(Type.COLD_CURRENT, 9)
	state.heating = true
	state.expire_effects(10)
	assert_null(state.active)
	assert_null(state.active_until_turn)
	assert_false(state.heating)


func test_expire_effects_without_an_active_effect_changes_nothing() -> void:
	var state := EventState.new()
	state.expire_effects(10)
	assert_null(state.active)
