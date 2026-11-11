class_name HistoryReports
extends RefCounted
## The reports a history entry reopens (lib/presentation/widgets/history/
## history_fight_launcher.dart, history_raid_launcher.dart,
## history_volcano_launcher.dart and history_assault_launcher.dart): a touch on
## a combat, a raid or a kraken wave rebuilds the report from the fight the
## entry stored and opens the page that told it the first time.
##
## The assault summary comes with the rival factions (lot 13): until then a
## [BaseAssaultEntry] has no page, nor a [CaptureEntry], tappable in Flutter
## too with no report behind it.


## The page that reopens the report of [param entry], null when it has none.
func page_for(entry: HistoryEntry) -> ModalPanel:
	if entry is CombatEntry:
		return FightSummaryPage.of_entry(entry as CombatEntry)
	if entry is RaidEntry:
		return RaidReportPage.new(raid_report(entry as RaidEntry))
	if entry is VolcanoEntry:
		return VolcanoReportPage.new(volcano_report(entry as VolcanoEntry))
	return null


## The report of the raid [param entry] stored, a school of predators under its
## own name.
static func raid_report(entry: RaidEntry) -> RaidReport:
	return RaidReport.new(entry.turn, entry.victory, entry.wave, entry.fight_result, entry.rampart_level,
		entry.defenders, entry.survivors_intact, entry.wounded, entry.dead, entry.loot, entry.pillaged,
		entry.surprise)


## The report of the kraken wave [param entry] stored.
static func volcano_report(entry: VolcanoEntry) -> VolcanoReport:
	return VolcanoReport.new(entry.turn, entry.victory, entry.wave, entry.fight_result, entry.kernel_level,
		entry.defenders, entry.survivors_intact, entry.wounded, entry.dead)
