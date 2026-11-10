extends TestCase
## test/domain/raid/raid_state_test.dart: the noise gauge of a player and
## the raid it announces.


func test_add_noise_fills_the_gauge_and_the_total() -> void:
	var state := RaidState.new()
	state.add_noise(5)
	state.add_noise(3)
	assert_eq(state.noise, 8)
	assert_eq(state.total_noise, 8)


func test_add_noise_ignores_non_positive_amounts() -> void:
	var state := RaidState.new()
	state.add_noise(0)
	state.add_noise(-4)
	assert_eq(state.total_noise, 0)


func test_quiet_lowers_the_gauge_but_keeps_the_total() -> void:
	var state := RaidState.new()
	state.add_noise(25)
	state.quiet(10)
	assert_eq(state.noise, 15)
	assert_eq(state.total_noise, 25)


func test_quiet_never_takes_the_gauge_below_zero() -> void:
	var state := RaidState.new()
	state.add_noise(4)
	state.quiet(10)
	assert_eq(state.noise, 0)
	assert_eq(state.total_noise, 4)


func test_announce_empties_the_gauge_but_keeps_the_total() -> void:
	var state := RaidState.new()
	state.add_noise(42)
	state.announce(_wave(), 12)
	assert_eq(state.noise, 0)
	assert_eq(state.total_noise, 42)
	assert_true(state.is_incoming())
	assert_eq(state.arrival_turn, 12)


func test_clear_incoming_forgets_the_announced_raid() -> void:
	var state := RaidState.new()
	state.announce(_wave(), 12)
	state.clear_incoming()
	assert_false(state.is_incoming())
	assert_null(state.arrival_turn)


func _wave() -> MonsterLair:
	return MonsterLair.new(MonsterDifficulty.Value.EASY, 8)
