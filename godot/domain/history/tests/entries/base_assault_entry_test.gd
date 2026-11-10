extends TestCase
## Not in the Dart files: lib/domain/history/entries/base_assault_entry.dart
## has no test of its own in test/domain. The line of an attack on a base,
## seen from either side.

const SCOUT := UnitType.Value.SCOUT


func test_keeps_both_sides_of_the_fight() -> void:
	var entry := BaseAssaultEntry.new(
		14, true, false, "Nacre", HistorySamples.fight(true),
		{SCOUT: 5}, {SCOUT: 2}, {SCOUT: 1}, {SCOUT: 2}, 2, 0, 5, 4,
		{ResourceType.Value.ORE: 30}, {ResourceType.Value.ORE: 25},
	)
	assert_eq(entry.turn, 14)
	assert_eq(entry.category, HistoryEntryCategory.Value.ASSAULT)
	assert_true(entry.victory)
	assert_false(entry.defending)
	assert_eq(entry.opponent_name, "Nacre")
	assert_eq(entry.fight_result.turn_count, 2)
	assert_eq([entry.units, entry.survivors_intact, entry.wounded, entry.dead].map(_scouts), [5, 2, 1, 2])
	assert_eq([entry.rampart_before, entry.rampart_after], [2, 0])
	assert_eq([entry.headquarters_before, entry.headquarters_after], [5, 4])
	assert_eq(entry.pillaged, {ResourceType.Value.ORE: 30})
	assert_eq(entry.loot, {ResourceType.Value.ORE: 25})


func test_an_attack_on_a_base_has_no_post_and_loses_nothing_with_it() -> void:
	var entry := HistorySamples.base_assault_entry(false, true)
	assert_null(entry.post_name)
	assert_true(entry.lost_with_post.is_empty())
	assert_true(entry.passage_destroyed)
	assert_true(entry.defending)


func test_an_attack_on_a_post_keeps_what_went_with_it() -> void:
	var entry := BaseAssaultEntry.new(
		30, true, true, "Nacre", HistorySamples.fight(true),
		{}, {}, {}, {}, 0, 0, 5, 5, {}, {}, "F-12", {SCOUT: 4}, false,
	)
	assert_eq(entry.post_name, "F-12")
	assert_eq(entry.lost_with_post, {SCOUT: 4})
	assert_false(entry.passage_destroyed)


func _scouts(units: Dictionary) -> int:
	return units[SCOUT]
