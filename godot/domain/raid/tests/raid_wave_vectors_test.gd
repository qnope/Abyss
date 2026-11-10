extends VectorTestCase
## reference/vectors/raids.json, wave and everyWave: the monster waves of a
## raid, as RaidWaveFactory answers in Dart, the families drawn by the seed.

var _vectors := VectorFile.new("raids")


func test_wave() -> void:
	var cases := _vectors.cases("wave")
	assert_eq(cases.size(), 96)
	for case: Dictionary in cases:
		var noise: int = case["noise"]
		var percent: int = case["percent"]
		var defence: int = case["defence"]
		var seed_: int = case["seed"]
		var wave := RaidWaveFactory.from_total_noise(noise, DartRandom.new(seed_), percent, defence)
		assert_same(RaidInputs.wave(wave), case["out"], str(case))


func test_every_wave() -> void:
	var cases := _vectors.cases("everyWave")
	assert_eq(cases.size(), 5)
	for case: Dictionary in cases:
		var noise: int = case["noise"]
		var percent: int = case["percent"]
		var written := []
		for wave: MonsterLair in RaidWaveFactory.every_from_total_noise(noise, percent):
			written.append(RaidInputs.wave(wave))
		assert_same(written, case["out"], str(case))
