extends VectorTestCase
## What a case of raids.json writes and reads.


func test_writes_a_wave_of_two_families() -> void:
	var lair := MonsterLair.new(
		MonsterDifficulty.Value.MEDIUM, 11, MonsterFamily.Value.HUNTER, MonsterFamily.Value.ARMOURED, 9
	)
	assert_same(RaidInputs.wave(lair), ["medium", "hunter", 11, "armoured", 9])


func test_writes_the_families_of_a_generic_lair_as_null() -> void:
	var lair := MonsterLair.new(MonsterDifficulty.Value.EASY, 5)
	assert_same(RaidInputs.wave(lair), ["easy", null, 5, null, 0])
