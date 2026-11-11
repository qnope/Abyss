class_name RequirementRow
extends HBoxContainer
## A line of an upgrade's list: an icon, a label that takes the width and, at
## the end, an amount, all in the error red until [member met]
## (UpgradeSection._row in lib/presentation/widgets/building/upgrade_section.dart).
## A cost, a prerequisite, a captured base to take.

const GAP := 8
const ICON_SIZE := 16.0

var met: bool
var label := Label.new()
var amount_label := Label.new()


## A row with [param icon], [param label_text] and [param amount] (none if
## empty), red unless [param is_met].
func _init(icon: Control, label_text: String, amount: String, is_met: bool) -> void:
	met = is_met
	add_theme_constant_override(&"separation", GAP)
	var color := AbyssColors.ON_SURFACE if met else AbyssColors.ERROR
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	amount_label.text = amount
	amount_label.visible = not amount.is_empty()
	for each: Label in [label, amount_label]:
		each.add_theme_color_override(&"font_color", color)
	add_child(icon)
	add_child(label)
	add_child(amount_label)


## A row with a padlock tinted by whether it is met.
static func locked(label_text: String, amount: String, is_met: bool) -> RequirementRow:
	var color := AbyssColors.ON_SURFACE if is_met else AbyssColors.ERROR
	return RequirementRow.new(UiIcon.glyph(&"lock", ICON_SIZE, color), label_text, amount, is_met)
