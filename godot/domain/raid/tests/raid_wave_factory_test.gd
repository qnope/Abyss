extends TestCase
## test/domain/raid/raid_wave_factory_test.dart: the monster wave of a raid,
## from the noise made so far. Its group 'a strong defence' is
## raid_wave_factory_a_strong_defence_test.gd.

const EASY := MonsterDifficulty.Value.EASY
const MEDIUM := MonsterDifficulty.Value.MEDIUM


## `expectShared`: `wave` holds `generic` generic monsters shared between
## its two families, the first one taking the larger half.
func _expect_shared(wave: MonsterLair, generic: int) -> void:
	assert_eq([wave.unit_count, wave.second_count], RaidSamples.shared_counts(wave, generic))


func test_weak_waves_hold_at_least_5_level_1_monsters() -> void:
	var wave := RaidWaveFactory.from_total_noise(10, DartRandom.new(1))
	assert_eq(wave.difficulty, EASY)
	_expect_shared(wave, 5)


func test_36_power_per_100_noise_one_level_1_monster_per_power_below_30() -> void:
	var wave := RaidWaveFactory.from_total_noise(50, DartRandom.new(1))
	assert_eq(wave.difficulty, EASY)
	_expect_shared(wave, 18)


func test_level_2_monsters_from_30_power_costing_2_power_each() -> void:
	assert_eq(RaidWaveFactory.from_total_noise(83).difficulty, EASY)
	assert_eq(RaidWaveFactory.from_total_noise(84).difficulty, MEDIUM)
	var wave := RaidWaveFactory.from_total_noise(150, DartRandom.new(1))
	assert_eq(wave.difficulty, MEDIUM)
	_expect_shared(wave, 27)


func test_level_3_monsters_from_80_power_costing_4_power_each() -> void:
	var wave := RaidWaveFactory.from_total_noise(400, DartRandom.new(1))
	assert_eq(wave.difficulty, MonsterDifficulty.Value.HARD)
	_expect_shared(wave, 36)


func test_a_wave_mixes_two_different_families_drawn_at_random() -> void:
	var seen := {}
	for seed_: int in 40:
		var wave := RaidWaveFactory.from_total_noise(150, DartRandom.new(seed_))
		assert_ne(wave.second_family, wave.family)
		for family: Variant in wave.groups():
			if family != null:
				seen[family] = true
	var every := {}
	for family: MonsterFamily.Value in MonsterFamily.available_at(3):
		every[family] = true
	assert_eq(seen.size(), every.size())
	for family: Variant in every:
		assert_true(seen.has(family))


func test_colossi_never_come_with_level_1_waves() -> void:
	for seed_: int in 40:
		var wave := RaidWaveFactory.from_total_noise(50, DartRandom.new(seed_))
		assert_false(wave.groups().has(MonsterFamily.Value.COLOSSUS))
