class_name HistoryEntryDisplay
extends RefCounted
## How a history entry looks and behaves
## (lib/presentation/extensions/history_entry_extensions.dart): the colour that
## tints its card, whether a touch opens something and the picture that takes
## the place of its category's glyph. The sealed-type switch is here, so that
## the card stays layout only. The words are `HistoryEntryTexts`.


## `accentColor`: wins glow green and losses red; every other entry takes the
## colour of its category, a capture the yellow of the energy.
static func accent_color(entry: HistoryEntry) -> Color:
	if entry is CombatEntry:
		return _outcome((entry as CombatEntry).victory)
	if entry is RaidEntry:
		return _outcome((entry as RaidEntry).victory)
	if entry is VolcanoEntry:
		return _outcome((entry as VolcanoEntry).victory)
	if entry is BaseAssaultEntry:
		var assault := entry as BaseAssaultEntry
		return _outcome(assault.victory != assault.defending)
	if entry is CaptureEntry:
		return AbyssColors.ENERGY_YELLOW
	return HistoryColors.of(entry.category)


## `isTappable`: only the entries that carry enough data (the whole fight) to
## be replayed: the fights, the captures, the raids, the waves and the
## assaults.
static func is_tappable(entry: HistoryEntry) -> bool:
	return entry is CombatEntry or entry is CaptureEntry or entry is RaidEntry \
		or entry is VolcanoEntry or entry is BaseAssaultEntry


## `illustration`: the file of the picture shown in place of the category's
## glyph: the event's, and the predators' for the fight of a school; "" for
## the others.
static func illustration(entry: HistoryEntry) -> String:
	if entry is EventEntry:
		return RandomEventTexts.illustration((entry as EventEntry).type)
	if entry is RaidEntry and (entry as RaidEntry).surprise:
		return RandomEventTexts.illustration(RandomEventType.Value.PREDATORS)
	return ""


static func _outcome(won: bool) -> Color:
	return AbyssColors.SUCCESS if won else AbyssColors.ERROR
