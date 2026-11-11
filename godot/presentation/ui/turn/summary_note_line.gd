class_name SummaryNoteLine
extends RefreshingPanel
## A line of the end-of-turn summary under another, without a glyph: indented
## and a little dimmer (the exploration's "(x, y) → n cellules"). The text
## comes from a [Callable] called again whenever the language changes, as a
## [SummaryLine]'s does.

const INDENT := 28
const TOP := 4
const DIM := 0.7

var label := Label.new()
var _text: Callable


## A line in [param color] saying what [param text] returns (a String).
func _init(color: Color, text: Callable) -> void:
	_text = text
	super()
	label.add_theme_color_override(&"font_color", Color(color, DIM))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var margin := MarginContainer.new()
	margin.add_theme_constant_override(&"margin_left", INDENT)
	margin.add_theme_constant_override(&"margin_top", TOP)
	margin.add_child(label)
	add_child(margin)
	refresh()


func refresh() -> void:
	label.text = str(_text.call())
