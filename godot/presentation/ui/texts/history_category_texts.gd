class_name HistoryCategoryTexts
extends RefCounted
## lib/presentation/extensions/history_entry_category_extensions.dart
## (HistoryEntryCategoryDisplay): the name of a kind of history entry in the
## language on, and its glyph, a file of `assets/icons/ui/` (Flutter's Material
## icon of the same name).


## `category.label(l10n)`: "Construction".
static func label(category: HistoryEntryCategory.Value) -> String:
	return Texts.t(TextKeys.of("historyCategory", HistoryEntryCategory.Value, category))


## `category.icon`: the name of the glyph.
static func icon(category: HistoryEntryCategory.Value) -> StringName:
	match category:
		HistoryEntryCategory.Value.COMBAT:
			return &"shield"
		HistoryEntryCategory.Value.BUILDING:
			return &"build"
		HistoryEntryCategory.Value.RESEARCH:
			return &"science"
		HistoryEntryCategory.Value.RECRUIT:
			return &"group_add"
		HistoryEntryCategory.Value.EXPLORE:
			return &"explore"
		HistoryEntryCategory.Value.COLLECT:
			return &"inventory"
		HistoryEntryCategory.Value.TURN_END:
			return &"hourglass_bottom"
		HistoryEntryCategory.Value.CAPTURE:
			return &"flag"
		HistoryEntryCategory.Value.DESCENT:
			return &"arrow_downward"
		HistoryEntryCategory.Value.REINFORCEMENT:
			return &"groups"
		HistoryEntryCategory.Value.RAID:
			return &"warning"
		HistoryEntryCategory.Value.VOLCANO:
			return &"volcano"
		HistoryEntryCategory.Value.EVENT:
			return &"auto_awesome"
	# HistoryEntryCategory.Value.ASSAULT
	return &"sports_kabaddi"
