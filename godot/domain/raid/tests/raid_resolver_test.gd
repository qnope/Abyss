extends TestCase
## test/domain/raid/raid_resolver_test.dart: the end-of-turn step of the
## raids. 'the raid is fought at the end of its arrival turn' without its
## two checks of the RaidEntry the history gets, which wait for the history
## module.

const HARPOONIST := UnitType.Value.HARPOONIST


func _gauged(units: Dictionary[UnitType.Value, int] = {}) -> Player:
	var player := RaidSamples.raid_player(units)
	player.raid_state.add_noise(NoiseRules.THRESHOLD)
	return player


func test_every_turn_adds_the_base_noise() -> void:
	var player := RaidSamples.raid_player()
	var outcome := RaidResolver.resolve(player, 3)
	assert_eq(player.raid_state.noise, NoiseRules.PER_TURN)
	assert_null(outcome.report)
	assert_null(outcome.announced)


func test_a_full_gauge_announces_a_raid_two_turns_ahead() -> void:
	var player := _gauged()
	var outcome := RaidResolver.resolve(player, 12)
	assert_not_null(outcome.announced)
	assert_eq(outcome.announced_turn, 14)
	assert_eq(player.raid_state.arrival_turn, 14)
	assert_eq(player.raid_state.noise, 0)


func test_no_raid_hits_before_the_first_raid_turn() -> void:
	var outcome := RaidResolver.resolve(_gauged(), 4)
	assert_eq(outcome.announced_turn, NoiseRules.FIRST_RAID_TURN)


func test_the_gauge_cannot_announce_a_second_raid_during_an_alert() -> void:
	var player := _gauged()
	RaidResolver.resolve(player, 12)
	player.raid_state.add_noise(NoiseRules.THRESHOLD)
	var outcome := RaidResolver.resolve(player, 13)
	assert_null(outcome.announced)
	assert_eq(player.raid_state.arrival_turn, 14)


func test_the_raid_is_fought_at_the_end_of_its_arrival_turn() -> void:
	var player := RaidSamples.raid_player()
	player.raid_state.announce(MonsterLair.new(MonsterDifficulty.Value.EASY, 5), 14)
	assert_null(RaidResolver.resolve(player, 13).report)
	var outcome := RaidResolver.resolve(player, 14, DartRandom.new(2))
	assert_false(outcome.report.victory)
	assert_false(player.raid_state.is_incoming())
	assert_eq(player.raid_state.lost_in_a_row, 1)
	assert_false(outcome.report.surprise)


func test_a_strong_base_draws_a_wave_sized_on_its_defenders() -> void:
	var weak := RaidResolver.resolve(_gauged(), 12, DartRandom.new(1)).announced
	var strong := RaidResolver.resolve(_gauged({HARPOONIST: 200}), 12, DartRandom.new(1)).announced
	assert_true(strong.level() > weak.level())


func test_a_faction_base_draws_a_wave_sized_on_its_defenders_too() -> void:
	var player := _gauged({HARPOONIST: 200})
	var outcome := RaidResolver.resolve(player, 12, DartRandom.new(1), Difficulty.Value.NORMAL, true, 3)
	assert_true(outcome.announced.level() > 1)
