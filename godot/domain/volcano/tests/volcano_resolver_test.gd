extends TestCase
## test/domain/volcano/volcano_resolver_test.dart: the end-of-turn step of
## the volcano. 'a wave beating an empty garrison takes a level off' without
## its check of the VolcanoEntry the history gets, which waits for the
## history module.

const NORMAL := Difficulty.Value.NORMAL


func _kernel_level(player: Player) -> int:
	return player.buildings[BuildingType.Value.VOLCANIC_KERNEL].level


func test_no_wave_while_the_kernel_is_at_level_0() -> void:
	var player := RaidSamples.volcano_player(0)
	var outcome := VolcanoResolver.resolve(player, 40)
	assert_null(outcome.announced)
	assert_false(player.volcano_state.is_incoming())


func test_a_kernel_at_level_1_or_more_draws_a_kraken_wave_for_next_turn() -> void:
	var player := RaidSamples.volcano_player(3)
	player.volcano_state.waves_repelled = 1
	var outcome := VolcanoResolver.resolve(player, 40)
	assert_eq(outcome.announced.family, MonsterFamily.Value.KRAKEN)
	assert_eq(
		outcome.announced.unit_count,
		VolcanoWaveFactory.krakens_for(3, Difficulty.monster_percent(NORMAL)),
	)
	assert_eq(player.volcano_state.arrival_turn, 41)


func test_the_waves_stop_once_the_kernel_reaches_level_10() -> void:
	var player := RaidSamples.volcano_player(10)
	assert_null(VolcanoResolver.resolve(player, 40).announced)


func test_a_wave_beating_an_empty_garrison_takes_a_level_off() -> void:
	var player := RaidSamples.volcano_player(4)
	VolcanoResolver.resolve(player, 40)
	var outcome := VolcanoResolver.resolve(player, 41, DartRandom.new(1))
	assert_false(outcome.report.victory)
	assert_eq(_kernel_level(player), 3)
	assert_eq(player.volcano_state.levels_lost, 1)
	assert_eq(
		outcome.announced.unit_count,
		VolcanoWaveFactory.krakens_for(3, Difficulty.monster_percent(NORMAL)),
	)


func test_a_strong_garrison_holds_the_kernel() -> void:
	var garrison: Dictionary[UnitType.Value, int] = {
		UnitType.Value.DOME_BREAKER: 60, UnitType.Value.GUARDIAN: 30
	}
	var player := RaidSamples.volcano_player(2, garrison)
	VolcanoResolver.resolve(player, 40)
	var outcome := VolcanoResolver.resolve(player, 41, DartRandom.new(2))
	assert_true(outcome.report.victory)
	assert_eq(_kernel_level(player), 2)
	assert_eq(player.volcano_state.waves_repelled, 1)
