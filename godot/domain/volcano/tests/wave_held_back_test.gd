extends TestCase
## test/domain/volcano/wave_held_back_test.dart: a wave due the turn the
## kernel lost a siege is held back one turn, or called off when the siege
## took the kernel.


func _kernel_level(player: Player) -> int:
	return player.buildings[BuildingType.Value.VOLCANIC_KERNEL].level


func test_a_wave_due_the_turn_the_kernel_lost_a_siege_comes_a_turn_later() -> void:
	var player := RaidSamples.volcano_player(4)
	VolcanoResolver.resolve(player, 40)
	var wave := player.volcano_state.incoming
	player.raid_state.kernel_siege_lost_turn = 41

	var outcome := VolcanoResolver.resolve(player, 41, DartRandom.new(1))

	assert_null(outcome.report)
	assert_eq(_kernel_level(player), 4)
	assert_eq(player.volcano_state.waves_fought(), 0)
	assert_true(player.volcano_state.incoming == wave)
	assert_eq(player.volcano_state.arrival_turn, 42)
	assert_true(outcome.announced == wave)


func test_the_held_back_wave_hits_at_the_end_of_the_next_turn() -> void:
	var player := RaidSamples.volcano_player(4)
	VolcanoResolver.resolve(player, 40)
	player.raid_state.kernel_siege_lost_turn = 41
	VolcanoResolver.resolve(player, 41, DartRandom.new(1))

	var outcome := VolcanoResolver.resolve(player, 42, DartRandom.new(1))

	assert_false(outcome.report.victory)
	assert_eq(_kernel_level(player), 3)
	assert_eq(player.volcano_state.arrival_turn, 43)


func test_a_siege_lost_an_earlier_turn_does_not_hold_the_wave_back() -> void:
	var player := RaidSamples.volcano_player(4)
	VolcanoResolver.resolve(player, 40)
	player.raid_state.kernel_siege_lost_turn = 40

	var outcome := VolcanoResolver.resolve(player, 41, DartRandom.new(1))

	assert_not_null(outcome.report)
	assert_eq(_kernel_level(player), 3)


func test_a_faction_kernel_is_held_back_the_same_way() -> void:
	var player := RaidSamples.volcano_player(4)
	VolcanoResolver.resolve(player, 40, null, Difficulty.Value.NORMAL, true)
	player.raid_state.kernel_siege_lost_turn = 41

	var outcome := VolcanoResolver.resolve(
		player, 41, DartRandom.new(1), Difficulty.Value.NORMAL, true
	)

	assert_null(outcome.report)
	assert_eq(player.volcano_state.arrival_turn, 42)


func test_a_siege_that_takes_the_kernel_calls_the_wave_off() -> void:
	var player := RaidSamples.volcano_player(4)
	VolcanoResolver.resolve(player, 40)
	player.buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 0
	player.raid_state.kernel_siege_lost_turn = 41

	var outcome := VolcanoResolver.resolve(player, 41, DartRandom.new(1))

	assert_null(outcome.report)
	assert_null(outcome.announced)
	assert_false(player.volcano_state.is_incoming())
	assert_eq(player.volcano_state.waves_fought(), 0)
