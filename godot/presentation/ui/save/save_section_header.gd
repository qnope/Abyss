class_name SaveSectionHeader
extends MarginContainer
## Small spaced capitals above a group of saves, such as "EN COURS"
## (lib/presentation/widgets/save/save_section_header.dart). The key of the
## text is kept, so that the header follows the language when the list
## calls [method refresh].

var label := Label.new()
var _key: StringName


func _init(key: StringName) -> void:
	_key = key
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override(&"margin_left", 4)
	add_theme_constant_override(&"margin_right", 4)
	add_theme_constant_override(&"margin_top", 20)
	add_theme_constant_override(&"margin_bottom", 10)
	label.theme_type_variation = &"SectionLabel"
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	refresh()


## Writes the header in capitals in the language on.
func refresh() -> void:
	label.text = Texts.t(_key).to_upper()
