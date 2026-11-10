extends TestCase
## Not in the Dart files: lib/domain/history/entries/volcano_entry.dart has
## no test of its own. The line of a kraken wave on the volcanic kernel.


func test_keeps_the_wave_the_kernel_and_the_garrison() -> void:
	var wave := MonsterLair.new(MonsterDifficulty.Value.HARD, 6)
	var entry := VolcanoEntry.new(
		20, false, wave, HistorySamples.fight(false), 2,
		{UnitType.Value.GUARDIAN: 4}, {}, {UnitType.Value.GUARDIAN: 1},
		{UnitType.Value.GUARDIAN: 3},
	)
	assert_eq(entry.turn, 20)
	assert_eq(entry.category, HistoryEntryCategory.Value.VOLCANO)
	assert_false(entry.victory)
	assert_true(entry.wave == wave)
	assert_false(entry.fight_result.is_victory())
	assert_eq(entry.kernel_level, 2)
	assert_eq(entry.defenders, {UnitType.Value.GUARDIAN: 4})
	assert_true(entry.survivors_intact.is_empty())
	assert_eq(entry.wounded, {UnitType.Value.GUARDIAN: 1})
	assert_eq(entry.dead, {UnitType.Value.GUARDIAN: 3})


func test_a_wave_pushed_back_is_a_victory() -> void:
	var entry := HistorySamples.volcano_entry(true)
	assert_true(entry.victory)
	assert_true(entry.fight_result.is_victory())
