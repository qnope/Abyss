extends TestCase
## The colours of history_entry_category_extensions.dart: backgroundColor.

const Category := HistoryEntryCategory.Value


func test_each_category_wears_the_colour_flutter_gives_it() -> void:
	var expected: Dictionary[HistoryEntryCategory.Value, Color] = {
		Category.COMBAT: AbyssColors.ERROR,
		Category.BUILDING: AbyssColors.CORAL_PINK,
		Category.RESEARCH: AbyssColors.BIOLUM_TEAL,
		Category.RECRUIT: AbyssColors.BIOLUM_PINK,
		Category.EXPLORE: AbyssColors.BIOLUM_CYAN,
		Category.COLLECT: AbyssColors.ALGAE_GREEN,
		Category.TURN_END: AbyssColors.BIOLUM_PURPLE,
		Category.CAPTURE: AbyssColors.ENERGY_YELLOW,
		Category.DESCENT: AbyssColors.BIOLUM_PURPLE,
		Category.REINFORCEMENT: AbyssColors.BIOLUM_TEAL,
		Category.RAID: AbyssColors.WARNING,
		Category.VOLCANO: AbyssColors.CORAL_PINK,
		Category.EVENT: AbyssColors.BIOLUM_CYAN,
		Category.ASSAULT: AbyssColors.CORAL_PINK,
	}
	assert_eq(expected.size(), Category.size())
	for category: Category in expected:
		assert_eq(HistoryColors.of(category), expected[category], str(category))
