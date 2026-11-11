class_name SummaryLine
extends RefreshingPanel
## One coloured line of the end-of-turn summary: a glyph and its text
## (lib/presentation/widgets/turn/summary_line.dart). The text comes from a
## [Callable] called again whenever the language changes, so the line follows
## it: `SummaryLine.new(&"shield", AbyssColors.SUCCESS, Texts.t.bind(&"turnRecruitAvailable"))`.

const ICON_SIZE := 20.0
const GAP := 8
const PADDING := 2

var icon: UiIcon
var label := Label.new()
var _text: Callable


## A line in [param color] beside the glyph [param glyph] (a file of
## assets/icons/ui), saying what [param text] returns (a String).
func _init(glyph: StringName, color: Color, text: Callable) -> void:
	_text = text
	super()
	icon = UiIcon.glyph(glyph, ICON_SIZE, color)
	label.add_theme_color_override(&"font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var margin := MarginContainer.new()
	margin.add_theme_constant_override(&"margin_top", PADDING)
	margin.add_theme_constant_override(&"margin_bottom", PADDING)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	row.add_child(icon)
	row.add_child(label)
	margin.add_child(row)
	add_child(margin)
	refresh()


func refresh() -> void:
	label.text = str(_text.call())
