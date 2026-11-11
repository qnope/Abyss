class_name LossSection
extends RefreshingPanel
## A divider, a titled header and one coloured line per loss
## (lib/presentation/widgets/turn/turn_loss_sections.dart): the buildings
## switched off and the units lost at the end of a turn, told before it and
## after it. The lines come from a [Callable] called again when the language
## changes.

const ICON_SIZE := 24.0
const GAP := 8

var title_label := Label.new()
var line_labels: Array[Label] = []
var _title_key: StringName
var _lines: Callable


## A section in [param color] titled by the text [param title_key], beside the
## glyph [param glyph]; [param lines] returns the PackedStringArray it lists.
func _init(glyph: StringName, color: Color, title_key: StringName, lines: Callable) -> void:
	_title_key = title_key
	_lines = lines
	super()
	var column := VBoxContainer.new()
	var header := HBoxContainer.new()
	header.add_theme_constant_override(&"separation", GAP)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(UiIcon.glyph(glyph, ICON_SIZE, color))
	header.add_child(title_label)
	column.add_child(HSeparator.new())
	column.add_child(header)
	var listed: PackedStringArray = _lines.call()
	for _line in listed:
		var label := Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_color_override(&"font_color", color)
		line_labels.append(label)
		column.add_child(label)
	title_label.add_theme_color_override(&"font_color", color)
	add_child(column)
	refresh()


func refresh() -> void:
	title_label.text = Texts.t(_title_key)
	var lines: PackedStringArray = _lines.call()
	for i in line_labels.size():
		line_labels[i].text = lines[i]
