extends TestCase
## test/domain/volcano/first_wave_test.dart: the first kraken wave a kernel
## holder faces comes at half strength.

const NORMAL := Difficulty.Value.NORMAL


func _full(level: int, difficulty: Difficulty.Value) -> int:
	return VolcanoWaveFactory.krakens_for(level, Difficulty.monster_percent(difficulty))


func _announced(player: Player, difficulty := NORMAL) -> int:
	return VolcanoResolver.resolve(player, 40, null, difficulty).announced.unit_count


func test_a_gentle_wave_holds_half_the_krakens_rounded_up_at_least_one() -> void:
	assert_eq(VolcanoWaveFactory.krakens_for(9, 100, true), 7)
	assert_eq(VolcanoWaveFactory.krakens_for(1, 100, true), 2)
	assert_eq(VolcanoWaveFactory.krakens_for(3, 100, true), 3)
	assert_eq(VolcanoWaveFactory.krakens_for(0, 1, true), 1)


func test_a_player_who_never_fought_a_wave_draws_a_half_strength_one() -> void:
	var player := RaidSamples.volcano_player(9)
	assert_eq(player.volcano_state.waves_fought(), 0)
	var size := _announced(player)
	assert_eq(size, DartMath.trunc_div(_full(9, NORMAL) + 1, 2))
	assert_eq(player.volcano_state.incoming.unit_count, size)
	assert_eq(player.volcano_state.arrival_turn, 41)


func test_the_wave_after_the_first_one_is_full_strength_again() -> void:
	var player := RaidSamples.volcano_player(6)
	VolcanoResolver.resolve(player, 40)
	var outcome := VolcanoResolver.resolve(player, 41, DartRandom.new(1))
	assert_eq(outcome.report.wave.unit_count, DartMath.trunc_div(_full(6, NORMAL) + 1, 2))
	assert_eq(player.volcano_state.waves_fought(), 1)
	assert_eq(outcome.announced.unit_count, _full(5, NORMAL))


func test_a_save_with_waves_already_fought_draws_a_normal_wave() -> void:
	for state: VolcanoState in [VolcanoState.new(null, null, 2), VolcanoState.new(null, null, 0, 1)]:
		var player := RaidSamples.volcano_player(9)
		player.volcano_state.waves_repelled = state.waves_repelled
		player.volcano_state.levels_lost = state.levels_lost
		assert_eq(_announced(player), _full(9, NORMAL))


func test_the_difficulty_still_scales_the_gentle_wave() -> void:
	for d: Difficulty.Value in Difficulty.Value.values():
		var player := RaidSamples.volcano_player(9)
		assert_eq(_announced(player, d), DartMath.trunc_div(_full(9, d) + 1, 2))
	var easy := _announced(RaidSamples.volcano_player(9), Difficulty.Value.EASY)
	assert_true(easy < _announced(RaidSamples.volcano_player(9), Difficulty.Value.HARD))


func test_a_faction_holding_the_kernel_gets_the_same_gentle_first_wave() -> void:
	var player := RaidSamples.volcano_player(9)
	var size := VolcanoResolver.resolve(player, 40, null, NORMAL, true).announced.unit_count
	var percent := Difficulty.monster_percent_for(NORMAL, true)
	assert_eq(size, VolcanoWaveFactory.krakens_for(9, percent, true))
