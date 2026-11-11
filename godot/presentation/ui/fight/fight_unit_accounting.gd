class_name FightUnitAccounting
extends FightReportCard
## The player's side of a fight report: for each unit type sent, how many came
## back intact, wounded or died (lib/presentation/widgets/fight/
## fight_unit_accounting.dart).

const PORTRAIT_SIZE := 28.0
const GAP := 8

var sent: Dictionary[UnitType.Value, int]
var intact: Dictionary[UnitType.Value, int]
var wounded: Dictionary[UnitType.Value, int]
var dead: Dictionary[UnitType.Value, int]
var title_label := text_label(&"TitleMedium", AbyssColors.BIOLUM_CYAN)
## The line of each type sent.
var rows: Dictionary[UnitType.Value, Label] = {}


func _init(
	sent_: Dictionary[UnitType.Value, int], intact_: Dictionary[UnitType.Value, int],
	wounded_: Dictionary[UnitType.Value, int], dead_: Dictionary[UnitType.Value, int]
) -> void:
	sent = sent_
	intact = intact_
	wounded = wounded_
	dead = dead_
	super()
	column.add_child(title_label)
	for type in sent:
		var label := text_label()
		rows[type] = label
		var row := HBoxContainer.new()
		row.add_theme_constant_override(&"separation", GAP)
		row.add_child(UnitPortrait.of(type, PORTRAIT_SIZE))
		row.add_child(label)
		column.add_child(row)
	refresh()


func refresh() -> void:
	title_label.text = Texts.t(&"fightYourUnits")
	for type in rows:
		rows[type].text = Texts.t(&"fightUnitAccounting", {
			"sent": sent.get(type, 0), "intact": intact.get(type, 0),
			"wounded": wounded.get(type, 0), "dead": dead.get(type, 0),
		})
