class_name FightReportCard
extends RefreshingPanel
## A card of a fight report: [member column] in the report's padding
## (lib/presentation/widgets/fight/fight_report_card.dart). The cards of the
## report derive from it and fill the column in `_init`, rewriting their texts
## in `refresh()`.

## The lines of the card, top to bottom.
var column := VBoxContainer.new()


func _init() -> void:
	super()
	theme_type_variation = AbyssCardTheme.PANEL
	add_child(column)


## A line of text in the card's ink, wrapped on its width.
static func text_label(role: StringName = &"BodyMedium", color := AbyssColors.ON_SURFACE) -> Label:
	var label := Label.new()
	label.theme_type_variation = role
	label.add_theme_color_override(&"font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label
