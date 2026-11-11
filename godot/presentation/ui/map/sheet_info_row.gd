class_name SheetInfoRow
extends HBoxContainer
## One line of a map sheet (lib/presentation/widgets/map/sheet_info_row.dart): a
## dim label on the left, its bold value on the right. Both are written by a
## function, so that the row follows the language by itself.

var label := Label.new()
var value_label := Label.new()
var _label_source: Callable
var _value_source: Callable


## A row whose label is [param label_source]'s text and its value
## [param value_source]'s (functions with no argument returning a String).
func _init(label_source: Callable, value_source: Callable) -> void:
	_label_source = label_source
	_value_source = value_source
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	value_label.theme_type_variation = &"LabelLarge"
	value_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE)
	add_child(label)
	add_child(value_label)
	refresh()


## Writes the label and the value again.
func refresh() -> void:
	label.text = _label_source.call()
	value_label.text = _value_source.call()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and _value_source.is_valid():
		refresh()
