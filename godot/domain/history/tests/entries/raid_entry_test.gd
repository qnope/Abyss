extends TestCase
## test/domain/history/entries/raid_entry_test.dart: a raid, or a school of
## predators fought like one.


func test_a_raid_is_a_raid_that_is_no_surprise() -> void:
	var entry := HistorySamples.raid_entry(true)
	assert_eq(entry.category, HistoryEntryCategory.Value.RAID)
	assert_true(entry.victory)
	assert_false(entry.surprise)


func test_a_school_of_predators_is_a_surprise_raid() -> void:
	var lost := HistorySamples.raid_entry(false, true)
	assert_eq(lost.category, HistoryEntryCategory.Value.RAID)
	assert_false(lost.victory)
	assert_true(lost.surprise)


## Not in the Dart file: what the raid took, cost and left, as given.
func test_keeps_the_wave_the_spoils_and_the_defenders() -> void:
	var wave := MonsterLair.new(MonsterDifficulty.Value.EASY, 5)
	var entry := RaidEntry.new(
		11, true, wave, HistorySamples.fight(true),
		{ResourceType.Value.CORAL: 9}, {ResourceType.Value.ALGAE: 4},
		{UnitType.Value.SCOUT: 3}, {UnitType.Value.SCOUT: 1}, {UnitType.Value.SCOUT: 1},
		{UnitType.Value.SCOUT: 1}, 2,
	)
	assert_eq(entry.turn, 11)
	assert_true(entry.wave == wave)
	assert_eq(entry.fight_result.turn_count, 2)
	assert_eq(entry.loot, {ResourceType.Value.CORAL: 9})
	assert_eq(entry.pillaged, {ResourceType.Value.ALGAE: 4})
	assert_eq(entry.defenders, {UnitType.Value.SCOUT: 3})
	assert_eq([entry.survivors_intact, entry.wounded, entry.dead].map(_scouts), [1, 1, 1])
	assert_eq(entry.rampart_level, 2)
	assert_false(entry.surprise)


func _scouts(units: Dictionary) -> int:
	return units[UnitType.Value.SCOUT]
