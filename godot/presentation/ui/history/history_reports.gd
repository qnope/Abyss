class_name HistoryReports
extends RefCounted
## The reports a history entry reopens (lib/presentation/widgets/history/
## history_fight_launcher.dart, history_raid_launcher.dart,
## history_volcano_launcher.dart and history_assault_launcher.dart): a touch on
## a combat, a raid, a kraken wave or an assault rebuilds the report from the
## fight the entry stored and opens the page that told it the first time.
##
## None of those pages exists yet, so [method page_for] returns null for every
## entry and a touch on a tappable card does nothing. The lot that builds a
## report page adds its branch here, building the page from the entry's fields
## the way the Dart launcher does (a test gives the sheet a subclass instead):
##
## - lot 10: a [CombatEntry] -> the fight summary (`FightMonsterResult.success`
##   from the entry's victory, fight, loot, sent, survivors, wounded and dead);
## - lot 11: a [RaidEntry] -> the raid report (a school of predators under its
##   own name), a [VolcanoEntry] -> the kraken wave report;
## - lot 13: a [BaseAssaultEntry] -> the assault summary, read from the side of
##   the player whose history it is.
##
## A [CaptureEntry] is tappable in Flutter too, with no report behind it.


## The page that reopens the report of [param _entry], null when it has none.
func page_for(_entry: HistoryEntry) -> ModalPanel:
	return null
