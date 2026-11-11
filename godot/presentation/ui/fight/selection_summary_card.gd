class_name SelectionSummaryCard
extends FightReportCard
## The totals under an army selection: the attack and the defence of the units
## picked, and the military bonus they fight with
## (lib/presentation/widgets/fight/selection_summary_card.dart). The owner
## tells the totals with [method show_totals] as the picks change.

const GAP := 8

var boost: UnitBoost
var atk_title := text_label(&"BodySmall", AbyssColors.ON_SURFACE_DIM)
var atk_value := text_label(&"TitleMedium")
var def_title := text_label(&"BodySmall", AbyssColors.ON_SURFACE_DIM)
var def_value := text_label(&"TitleMedium")
var bonus_label := text_label(&"BodyMedium", AbyssColors.ON_SURFACE_DIM)


func _init(boost_: UnitBoost) -> void:
	boost = boost_
	super()
	var totals := HBoxContainer.new()
	totals.add_child(_stat(atk_title, atk_value))
	totals.add_child(_stat(def_title, def_value))
	column.add_theme_constant_override(&"separation", GAP)
	column.add_child(totals)
	column.add_child(bonus_label)
	show_totals(0, 0)
	refresh()


## A column of a title over its value, sharing the width with its neighbour.
func _stat(title: Label, value: Label) -> VBoxContainer:
	var stat := VBoxContainer.new()
	stat.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stat.add_child(title)
	stat.add_child(value)
	return stat


## Writes the totals [param atk] and [param def].
func show_totals(atk: int, def: int) -> void:
	atk_value.text = str(atk)
	def_value.text = str(def)


func refresh() -> void:
	atk_title.text = Texts.t(&"statAttack")
	def_title.text = Texts.t(&"statDefense")
	bonus_label.text = _bonus_text()


## "Military bonus: +30% ATK, +10% DEF", or that there is none.
func _bonus_text() -> String:
	var parts := PackedStringArray()
	var percents: Array[int] = [boost.atk_percent, boost.def_percent, boost.hp_percent]
	var stats: Array[StringName] = [&"statAttack", &"statDefense", &"statHp"]
	for i in percents.size():
		if percents[i] > 0:
			parts.append("+%d%% %s" % [percents[i], Texts.t(stats[i])])
	if parts.is_empty():
		return Texts.t(&"fightMilitaryBonusNone")
	return Texts.t(&"fightMilitaryBonus", {"bonuses": ", ".join(parts)})
