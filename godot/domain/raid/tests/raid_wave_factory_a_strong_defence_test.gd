extends TestCase
## test/domain/raid/raid_wave_factory_test.dart, group 'a strong defence':
## a garrison strong enough draws a wave sized on its strength.


func _expect_shared(wave: MonsterLair, generic: int) -> void:
	assert_eq([wave.unit_count, wave.second_count], RaidSamples.shared_counts(wave, generic))


func test_without_defenders_the_wave_follows_the_noise_alone() -> void:
	var noise := RaidWaveFactory.from_total_noise(50, DartRandom.new(1))
	var same := RaidWaveFactory.from_total_noise(50, DartRandom.new(1), 100, 0)
	assert_eq(RaidSamples.wave_fields(same), RaidSamples.wave_fields(noise))


func test_draws_a_wave_of_75_percent_of_its_strength_when_it_beats_the_noise() -> void:
	var wave := RaidWaveFactory.from_total_noise(50, DartRandom.new(1), 100, 40)
	assert_eq(RaidWaveFactory.DEFENCE_SHARE_PERCENT, 75)
	_expect_shared(wave, DartMath.trunc_div(30, 2)) # 30 power of level 2 monsters
	assert_eq(wave.difficulty, MonsterDifficulty.Value.MEDIUM)


func test_a_weak_defence_leaves_the_noise_in_charge() -> void:
	var noise := RaidWaveFactory.from_total_noise(200, DartRandom.new(1))
	var weak := RaidWaveFactory.from_total_noise(200, DartRandom.new(1), 100, 10)
	assert_eq(RaidSamples.wave_fields(weak), RaidSamples.wave_fields(noise))


func test_the_difficulty_scales_the_defence_share_too() -> void:
	var wave := RaidWaveFactory.from_total_noise(0, DartRandom.new(1), 50, 40)
	_expect_shared(wave, 15)
	assert_eq(wave.difficulty, MonsterDifficulty.Value.EASY)
