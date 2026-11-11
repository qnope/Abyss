class_name HistoryColors
## The colour of each kind of history entry
## (lib/presentation/extensions/history_entry_category_extensions.dart:
## backgroundColor): the theme's roles of Flutter's `ColorScheme` (primary
## cyan, secondary teal, tertiary purple, error red) and the palette's glows,
## so that a card's tint and its icon say what the entry tells of.


## `category.backgroundColor(theme)`.
static func of(category: HistoryEntryCategory.Value) -> Color:
	match category:
		HistoryEntryCategory.Value.COMBAT:
			return AbyssColors.ERROR
		HistoryEntryCategory.Value.BUILDING, HistoryEntryCategory.Value.VOLCANO, HistoryEntryCategory.Value.ASSAULT:
			return AbyssColors.CORAL_PINK
		HistoryEntryCategory.Value.RESEARCH, HistoryEntryCategory.Value.REINFORCEMENT:
			return AbyssColors.BIOLUM_TEAL
		HistoryEntryCategory.Value.RECRUIT:
			return AbyssColors.BIOLUM_PINK
		HistoryEntryCategory.Value.EXPLORE, HistoryEntryCategory.Value.EVENT:
			return AbyssColors.BIOLUM_CYAN
		HistoryEntryCategory.Value.COLLECT:
			return AbyssColors.ALGAE_GREEN
		HistoryEntryCategory.Value.TURN_END, HistoryEntryCategory.Value.DESCENT:
			return AbyssColors.BIOLUM_PURPLE
		HistoryEntryCategory.Value.CAPTURE:
			return AbyssColors.ENERGY_YELLOW
	# HistoryEntryCategory.Value.RAID
	return AbyssColors.WARNING
