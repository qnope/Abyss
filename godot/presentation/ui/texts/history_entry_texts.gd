class_name HistoryEntryTexts
extends RefCounted
## lib/presentation/extensions/history_entry_texts.dart (HistoryEntryTexts):
## the title and the subtitle of a history entry, worded in the language on
## from the entry's data. The French texts older saves stored are not shown.


## `entry.displayTitle(l10n)`: "3 éclaireurs recrutés".
static func title(entry: HistoryEntry) -> String:
	if entry is BuildingEntry:
		var building := entry as BuildingEntry
		return Texts.t(&"historyBuildingTitle", {
			"building": BuildingTexts.display_name(building.building_type), "level": building.new_level})
	if entry is ResearchEntry:
		return _research(entry as ResearchEntry)
	if entry is RecruitEntry:
		var recruit := entry as RecruitEntry
		return Texts.t(&"historyRecruitTitle", {
			"count": recruit.quantity, "units": UnitTexts.units(recruit.unit_type, recruit.quantity)})
	if entry is ExploreEntry:
		var explore := entry as ExploreEntry
		return Texts.t(&"historyExploreTitle", {"x": explore.target_x, "y": explore.target_y})
	if entry is CollectEntry:
		var collect := entry as CollectEntry
		return Texts.t(&"historyCollectTitle", {"x": collect.target_x, "y": collect.target_y})
	if entry is CombatEntry:
		var combat := entry as CombatEntry
		var key := &"historyCombatVictory" if combat.victory else &"historyCombatDefeat"
		return Texts.t(key, {"level": combat.lair.level()})
	if entry is TurnEndEntry:
		return Texts.t(&"historyTurnEndTitle", {"turn": entry.turn})
	if entry is CaptureEntry:
		return _capture(entry as CaptureEntry)
	if entry is DescentEntry:
		return Texts.t(&"historyDescentTitle", {"level": (entry as DescentEntry).target_level})
	if entry is ReinforcementEntry:
		return Texts.t(&"historyReinforcementTitle", {"level": (entry as ReinforcementEntry).target_level})
	if entry is RaidEntry:
		return _raid(entry as RaidEntry)
	if entry is VolcanoEntry:
		return Texts.t(&"historyVolcanoRepelled" if (entry as VolcanoEntry).victory else &"historyVolcanoLost")
	if entry is EventEntry:
		return RandomEventTexts.label((entry as EventEntry).type)
	return _assault(entry as BaseAssaultEntry)


## `entry.displaySubtitle(l10n)`: the detail under the title, null when the
## entry has none.
static func subtitle(entry: HistoryEntry) -> Variant:
	if entry is CaptureEntry:
		var capture := entry as CaptureEntry
		if not capture.captured:
			return Texts.t(&"historyCaptureAdmiralFell")
		return Texts.t(&"historyCaptureVictory", {"turns": capture.fight_result.turn_count})
	if entry is DescentEntry:
		return Texts.t(&"historyDescentUnits", {"count": (entry as DescentEntry).unit_count})
	if entry is ReinforcementEntry:
		return Texts.t(&"historyReinforcementUnits", {"count": (entry as ReinforcementEntry).unit_count})
	if entry is EventEntry:
		return _event_choice(entry as EventEntry)
	return null


static func _research(entry: ResearchEntry) -> String:
	var branch := TechBranchTexts.display_name(entry.branch)
	if entry.is_unlock:
		return Texts.t(&"historyResearchUnlocked", {"branch": branch})
	if entry.new_level != null:
		return Texts.t(&"historyResearchLevel", {"branch": branch, "level": entry.new_level})
	return Texts.t(&"historyResearchImproved", {"branch": branch})


static func _capture(entry: CaptureEntry) -> String:
	var name := BuildingTexts.display_name(BuildingType.Value.VOLCANIC_KERNEL) if entry.is_volcanic_kernel() \
		else TransitionBaseNameTexts.label(entry.transition_base_name)
	return Texts.t(&"historyCaptureTitle" if entry.captured else &"historyCaptureMissed", {"name": name})


static func _raid(entry: RaidEntry) -> String:
	if entry.surprise:
		return Texts.t(&"historyPredatorsRepelled" if entry.victory else &"historyPredatorsLost")
	return Texts.t(&"historyRaidRepelled" if entry.victory else &"historyRaidLost")


static func _assault(entry: BaseAssaultEntry) -> String:
	var name := AttackerNameTexts.label(entry.opponent_name)
	var code: Variant = entry.post_name
	if code != null and code != CaptureEntry.VOLCANIC_KERNEL:
		var post: String = code
		var args := {"post": TransitionBaseNameTexts.label(post), "name": name}
		if entry.defending:
			return Texts.t(&"historyPostSuffered" if entry.victory else &"historyPostRepelled", args)
		return Texts.t(&"historyPostWon" if entry.victory else &"historyPostFailed", args)
	if entry.defending:
		return Texts.t(&"historyAssaultSuffered" if entry.victory else &"historyAssaultRepelled", {"name": name})
	return Texts.t(&"historyAssaultWon" if entry.victory else &"historyAssaultFailed", {"name": name})


## The choice the player made, for an event that offered one.
static func _event_choice(entry: EventEntry) -> Variant:
	if not RandomEventChoice.has_choice(entry.type):
		return null
	if entry.defaulted:
		return Texts.t(&"historyEventDefaulted")
	return Texts.t(&"historyEventAccepted" if entry.accepted else &"historyEventRefused")
