extends TestCase
## test/domain/history/entries/research_entry_test.dart: the line of a
## branch unlocked or researched.


func test_research_entry_unlock_variant_has_no_level() -> void:
	var entry := ResearchEntry.new(4, TechBranch.Value.MILITARY, true)
	assert_eq(entry.category, HistoryEntryCategory.Value.RESEARCH)
	assert_true(entry.is_unlock)
	assert_null(entry.new_level)
	assert_eq(entry.branch, TechBranch.Value.MILITARY)


func test_research_entry_research_variant_includes_new_level() -> void:
	var entry := ResearchEntry.new(7, TechBranch.Value.RESOURCES, false, 3)
	assert_false(entry.is_unlock)
	assert_eq(entry.new_level, 3)
	assert_eq(entry.branch, TechBranch.Value.RESOURCES)
	assert_eq(entry.turn, 7)
