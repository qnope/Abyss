class_name AttackTurnSection
extends RefreshingPanel
## The attacks of the factions on the human this turn, on its base, its posts or
## its kernel, in the end-of-turn summary (lib/presentation/widgets/turn/
## attack_turn_section.dart): the lines of each ([AttackReportLines]) and a button
## that opens the report of the fight over the summary. [AttackSections] builds
## it only when the turn had an attack.

const GAP := 4

var reports: Array[FactionAttackReport]
## The lines of each attack, and the button that reads its report.
var lines: Array[AttackReportLines] = []
var report_buttons: Array[Button] = []


func _init(reports_: Array[FactionAttackReport]) -> void:
	reports = reports_
	super()
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", GAP)
	column.add_child(HSeparator.new())
	for report in reports:
		var attack := AttackReportLines.new(report)
		lines.append(attack)
		column.add_child(attack)
		var button := Button.new()
		button.theme_type_variation = &"TextButton"
		button.size_flags_horizontal = Control.SIZE_SHRINK_END
		button.pressed.connect(_read.bind(report))
		report_buttons.append(button)
		column.add_child(button)
	add_child(column)
	refresh()


func refresh() -> void:
	for button in report_buttons:
		button.text = Texts.t(&"factionAttackReport")


## Opens the report of [param report] over the dialog that holds the section.
func _read(report: FactionAttackReport) -> void:
	var layer := ModalLayer.enclosing(self)
	if layer != null:
		layer.open(BaseAssaultSummaryPage.new(report.entry))
