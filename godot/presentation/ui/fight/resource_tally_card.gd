class_name ResourceTallyCard
extends FightReportCard
## A titled list of resources with an amount each, or a line saying there were
## none: the loot of a fight ([FightLootCard]) and what a lost raid carried
## away ([RaidPillageCard]) are the same card with another title, colour and
## sign. Amounts of zero are left out.

const ICON_SIZE := 20.0
const GAP := 8

var title_key: StringName
var empty_key: StringName
var amounts: Dictionary[ResourceType.Value, int]
## "+" for what was won, "-" for what was lost.
var sign_text: String
var title_label := text_label(&"TitleMedium")
var empty_label := text_label(&"BodyMedium", AbyssColors.ON_SURFACE_DIM)
## The resources shown, each with the label that names it and its amount.
var rows: Dictionary[ResourceType.Value, Label] = {}


func _init(
	title_key_: StringName, color: Color, empty_key_: StringName,
	amounts_: Dictionary[ResourceType.Value, int], sign_text_: String
) -> void:
	title_key = title_key_
	empty_key = empty_key_
	amounts = amounts_
	sign_text = sign_text_
	super()
	title_label.add_theme_color_override(&"font_color", color)
	column.add_child(title_label)
	for type in amounts:
		if amounts[type] == 0:
			continue
		var label := text_label()
		rows[type] = label
		var row := HBoxContainer.new()
		row.add_theme_constant_override(&"separation", GAP)
		row.add_child(ResourceIcon.new(type, ICON_SIZE))
		row.add_child(label)
		column.add_child(row)
	empty_label.visible = rows.is_empty()
	column.add_child(empty_label)
	refresh()


func refresh() -> void:
	title_label.text = Texts.t(title_key)
	empty_label.text = Texts.t(empty_key)
	for type in rows:
		rows[type].text = "%s %s%d" % [ResourceTexts.display_name(type), sign_text, absi(amounts[type])]
