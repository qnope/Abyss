class_name MonsterFamilyTraits
extends RefreshingPanel
## The rule of a monster family and the unit that answers it. It shows nothing
## for the generic monsters of older games
## (lib/presentation/widgets/fight/monster_family_traits.dart).

const ICON_SIZE := 16.0
const GAP := 6

## A MonsterFamily.Value, or null for the generic monsters.
var family: Variant
var rule_label := FightReportCard.text_label()
var weakness_label := FightReportCard.text_label(&"BodyMedium", AbyssColors.SUCCESS)


func _init(family_: Variant) -> void:
	family = family_
	super()
	visible = family != null
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", GAP)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	row.add_child(UiIcon.glyph(&"flag", ICON_SIZE, AbyssColors.SUCCESS))
	row.add_child(weakness_label)
	column.add_child(rule_label)
	column.add_child(row)
	add_child(column)
	refresh()


func refresh() -> void:
	if family == null:
		return
	rule_label.text = str(MonsterFamilyTexts.rule(family))
	weakness_label.text = Texts.t(&"fightWeakAgainst", {"unit": MonsterFamilyTexts.weakness(family)})
