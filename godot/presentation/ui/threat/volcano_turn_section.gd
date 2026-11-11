class_name VolcanoTurnSection
extends VBoxContainer
## The volcano lines of the end-of-turn summary: the kraken wave just fought
## on the kernel and the one just announced (lib/presentation/widgets/volcano/
## volcano_turn_section.dart). [ThreatSections] builds it only when the turn
## had one of the two.

## The wave fought, null when none was.
var fought_line: SummaryLine
## The wave announced, null when none was.
var announced_line: SummaryLine


func _init(result: TurnResult) -> void:
	add_child(HSeparator.new())
	var fought := result.volcano
	if fought != null:
		fought_line = SummaryLine.new(
			&"shield" if fought.victory else &"volcano",
			AbyssColors.SUCCESS if fought.victory else AbyssColors.ERROR,
			_repelled.bind(fought) if fought.victory else Texts.t.bind(&"volcanoKernelFell", {"level": fought.kernel_level_after()}))
		add_child(fought_line)
	var announced := result.announced_wave
	if announced != null:
		announced_line = SummaryLine.new(&"warning", AbyssColors.WARNING, func() -> String:
			return Texts.t(&"volcanoKrakenRises", {"wave": MonsterLairTexts.wave_label(announced)}))
		add_child(announced_line)


## "Volcan : vague repoussée, 1 blessé, 2 morts".
static func _repelled(report: VolcanoReport) -> String:
	var losses := "%s, %s" % [
		Texts.t(&"volcanoWounded", {"count": _total(report.wounded)}),
		Texts.t(&"volcanoDead", {"count": _total(report.dead)}),
	]
	return Texts.t(&"volcanoRepelled", {"losses": losses})


static func _total(units: Dictionary[UnitType.Value, int]) -> int:
	var total := 0
	for count: int in units.values():
		total += count
	return total
