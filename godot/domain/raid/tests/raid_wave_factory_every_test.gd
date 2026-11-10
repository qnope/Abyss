extends TestCase
## test/domain/raid/raid_wave_factory_every_test.dart: every wave a noise
## can draw, so a defence can be checked against all of them.


func test_holds_one_wave_for_each_ordered_pair_of_families() -> void:
	# Level 1 monsters come in 3 families, tougher ones in 4.
	assert_eq(RaidWaveFactory.every_from_total_noise(10).size(), 6)
	assert_eq(RaidWaveFactory.every_from_total_noise(3000).size(), 12)


func test_holds_every_wave_the_noise_can_draw_and_only_those() -> void:
	for noise: int in [10, 300, 3000]:
		var every := {}
		for wave: MonsterLair in RaidWaveFactory.every_from_total_noise(noise, 70):
			every[str(RaidSamples.wave_fields(wave))] = true
		var drawn := {}
		for seed_: int in 200:
			var wave := RaidWaveFactory.from_total_noise(noise, DartRandom.new(seed_), 70)
			drawn[str(RaidSamples.wave_fields(wave))] = true
		assert_eq(drawn.size(), every.size(), "noise %d" % noise)
		for key: String in every:
			assert_true(drawn.has(key), "noise %d: %s" % [noise, key])
