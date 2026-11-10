extends TestCase
## test/domain/event/event_resolver_current_test.dart: the currents at the
## end of a turn.

const COLD := RandomEventType.Value.COLD_CURRENT


func test_a_cold_current_left_without_a_choice_starts_with_the_next_turn() -> void:
	var player := EventSamples.event_player()
	player.event_state.schedule(100)
	player.event_state.set_pending(COLD, 12)
	EventResolver.resolve(EventSamples.event_game(player, 12), player, 12, DartRandom.new(1))
	var state := player.event_state
	assert_eq(state.active, COLD)
	assert_true(state.is_active(COLD, 13))
	assert_eq(state.active_until_turn, 12 + EventRules.EFFECT_TURNS)
	assert_false(state.heating)


func test_a_warm_current_makes_noise_up_to_its_last_turn_then_ends() -> void:
	var player := EventSamples.event_player()
	player.event_state.schedule(100)
	player.event_state.activate(RandomEventType.Value.WARM_CURRENT, 14)
	var game := EventSamples.event_game(player, 12)
	var noise: Array[int] = []
	for turn: int in range(12, 17):
		var before := player.raid_state.total_noise
		EventResolver.resolve(game, player, turn, DartRandom.new(1))
		noise.append(player.raid_state.total_noise - before)
	assert_eq(noise, [3, 3, 3, 0, 0])
	assert_null(player.event_state.active)


## Not in the Dart file: a current left past its last turn makes no more
## noise, and ends.
func test_a_warm_current_past_its_last_turn_makes_no_noise_and_ends() -> void:
	var player := EventSamples.event_player()
	player.event_state.schedule(100)
	player.event_state.activate(RandomEventType.Value.WARM_CURRENT, 9)
	EventResolver.resolve(EventSamples.event_game(player, 12), player, 12, DartRandom.new(1))
	assert_eq(player.raid_state.total_noise, 0)
	assert_null(player.event_state.active)
