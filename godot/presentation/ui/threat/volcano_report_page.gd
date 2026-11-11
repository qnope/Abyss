class_name VolcanoReportPage
extends ThreatReportPage
## The report of a kraken wave on the kernel: the fight's cards, plus the
## kernel at stake and its magma rampart (lib/presentation/screens/game/
## volcano/volcano_summary_screen.dart).

var report: VolcanoReport


func _init(report_: VolcanoReport) -> void:
	report = report_
	super(Texts.t.bind(&"volcanoWaveTitle", {"turn": report.turn}))
	add_card(FightResultBanner.new(report.victory, report.fight.turn_count))
	add_card(_kernel_card())
	add_card(MonsterPreview.new(report.wave))
	if not report.defenders.is_empty():
		add_card(FightUnitAccounting.new(report.defenders, report.survivors_intact, report.wounded, report.dead))
	add_card(FightKillCount.new(report.fight))
	add_card(FightTurnList.new(report.fight.turn_summaries))
	add_back_button()


func _kernel_card() -> ThreatInfoCard:
	var level := report.kernel_level
	var title := Texts.t.bind(&"volcanoKernelHolds", {"level": level}) if report.victory \
			else Texts.t.bind(&"volcanoKernelDrops", {"level": report.kernel_level_after()})
	var subtitle := Callable()
	if level > 0:
		subtitle = func() -> String:
			return Texts.t(&"volcanoMagmaRampart", {"stats": RampartTexts.magma(level)})
	return ThreatInfoCard.new(&"volcano", AbyssColors.CORAL_PINK if report.victory else AbyssColors.ERROR, title, subtitle)
