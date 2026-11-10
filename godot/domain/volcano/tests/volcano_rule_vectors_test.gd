extends VectorTestCase
## reference/vectors/raids.json, krakens, and fight_rules.json, magmaRampart:
## the size of a kraken wave and the rampart of a kernel, as the Dart rules
## answer.


func test_krakens() -> void:
	var cases := VectorFile.new("raids").cases("krakens")
	assert_eq(cases.size(), 154)
	for case: Dictionary in cases:
		var level: int = case["level"]
		var percent: int = case["percent"]
		var first: bool = case["firstWave"]
		assert_same(VolcanoWaveFactory.krakens_for(level, percent, first), case["out"], str(case))
		var wave := VolcanoWaveFactory.from_kernel_level(level, percent, first)
		assert_same(RaidInputs.wave(wave), ["hard", "kraken", case["out"], null, 0], str(case))


func test_magma_rampart() -> void:
	var cases := VectorFile.new("fight_rules").cases("magmaRampart")
	assert_eq(cases.size(), 11)
	for case: Dictionary in cases:
		var level: int = case["level"]
		var rampart := MagmaRampart.combatant_for(level)
		var out: Variant = null
		if rampart != null:
			var side: Array[Combatant] = [rampart]
			out = FightInputs.runs_of(side)[0]
		assert_same(out, case["out"], str(case))
