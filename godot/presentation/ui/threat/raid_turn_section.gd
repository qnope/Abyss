class_name RaidTurnSection
extends VBoxContainer
## The raid lines of the end-of-turn summary: the raid just fought and the
## raid just announced (lib/presentation/widgets/raid/raid_turn_section.dart).
## [ThreatSections] builds it only when the turn had one of the two.

## The raid fought, null when none was.
var fought_line: SummaryLine
## The raid announced, null when none was.
var announced_line: SummaryLine


func _init(result: TurnResult) -> void:
	add_child(HSeparator.new())
	var raid := result.raid
	if raid != null:
		fought_line = SummaryLine.new(
			&"shield" if raid.victory else &"dangerous",
			AbyssColors.SUCCESS if raid.victory else AbyssColors.ERROR,
			Texts.t.bind(&"historyRaidRepelled" if raid.victory else &"raidBaseLooted"))
		add_child(fought_line)
	var announced := result.announced_raid
	if announced != null:
		var turn: int = result.announced_raid_turn if result.announced_raid_turn != null else 0
		announced_line = SummaryLine.new(&"warning", AbyssColors.WARNING, func() -> String:
			return Texts.t(&"raidAnnounced", {"wave": MonsterLairTexts.wave_label(announced), "turn": turn}))
		add_child(announced_line)
