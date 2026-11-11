class_name RaidReportPage
extends ThreatReportPage
## The report of a raid on the base, or of a school of predators fought like
## one: the fight's cards, the Citadel rampart and what the monsters carried
## away (lib/presentation/screens/game/raid/raid_summary_screen.dart).

var report: RaidReport


func _init(report_: RaidReport) -> void:
	report = report_
	super(Texts.t.bind(&"raidPredatorsTitle" if report.surprise else &"raidTitle", {"turn": report.turn}))
	add_card(FightResultBanner.new(report.victory, report.fight.turn_count))
	add_card(MonsterPreview.new(report.wave))
	if report.rampart_level > 0:
		add_card(ThreatInfoCard.new(&"fort", AbyssColors.CORAL_PINK,
			Texts.t.bind(&"raidRampart", {"level": report.rampart_level}),
			RampartTexts.coral.bind(report.rampart_level)))
	if not report.defenders.is_empty():
		add_card(FightUnitAccounting.new(report.defenders, report.survivors_intact, report.wounded, report.dead))
	add_card(FightKillCount.new(report.fight))
	if report.victory:
		add_card(FightLootCard.new(report.loot))
	else:
		add_card(RaidPillageCard.new(report.pillaged))
	add_card(FightTurnList.new(report.fight.turn_summaries))
	add_back_button()
