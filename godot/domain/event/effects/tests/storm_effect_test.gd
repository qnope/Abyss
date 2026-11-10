extends TestCase
## test/domain/event/effects/storm_effect_test.dart: the storm, which forbids
## exploring and covers the noise.

const Type := RandomEventType.Value

var _storm := StormEffect.new()


func _player_with_noise(noise: int) -> Player:
	var player := EventSamples.event_player()
	player.raid_state.add_noise(noise)
	return player


func test_a_storm_drawn_at_the_end_of_turn_12_lasts_through_turns_13_and_14() -> void:
	var player := EventSamples.event_player()
	_storm.apply(EventSamples.event_game(player, 12), player, true, 13)
	var state := player.event_state
	assert_eq(state.active, Type.STORM)
	assert_eq(state.active_until_turn, 13 + EventRules.STORM_TURNS - 1)
	assert_true(state.is_active(Type.STORM, 14))
	assert_false(state.is_active(Type.STORM, 15))


func test_a_storm_takes_10_points_off_the_gauge_not_off_the_total() -> void:
	var player := _player_with_noise(25)
	_storm.apply(EventSamples.event_game(player, 12), player, true, 13)
	assert_eq(player.raid_state.noise, 25 - EventRules.STORM_NOISE_RELIEF)
	assert_eq(player.raid_state.total_noise, 25)


func test_a_storm_never_takes_the_gauge_below_zero() -> void:
	var player := _player_with_noise(6)
	_storm.apply(EventSamples.event_game(player, 12), player, true, 13)
	assert_eq(player.raid_state.noise, 0)
	assert_eq(player.raid_state.total_noise, 6)
