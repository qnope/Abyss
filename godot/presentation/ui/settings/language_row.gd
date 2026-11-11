class_name LanguageRow
extends Button
## One choice of the language picker: its name in itself (or "Automatic" with
## its hint), a check mark when it is the one picked
## (lib/presentation/widgets/common/language_picker.dart: _LanguageRow). The
## whole row is the touch area.

const HEIGHT := 56.0
const HINT_HEIGHT := 72.0

var choice: LanguageChoice.Value
var name_label := Label.new()
var hint_label := Label.new()
var check := UiIcon.glyph(&"check", 24.0, AbyssColors.BIOLUM_CYAN)


func _init(choice_: LanguageChoice.Value) -> void:
	choice = choice_
	theme_type_variation = AbyssSurfaceTheme.TAP
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var lines := VBoxContainer.new()
	lines.alignment = BoxContainer.ALIGNMENT_CENTER
	lines.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lines.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.theme_type_variation = &"TitleMedium"
	hint_label.theme_type_variation = &"BodySmall"
	hint_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	for node: Control in [name_label, hint_label]:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lines.add_child(node)
	check.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(lines)
	row.add_child(check)
	add_child(row)
	var automatic := choice == LanguageChoice.Value.AUTOMATIC
	hint_label.visible = automatic
	custom_minimum_size.y = HINT_HEIGHT if automatic else HEIGHT
	set_selected(false)
	refresh()


## Writes the name (and the hint of "Automatic") in the language on.
func refresh() -> void:
	name_label.text = LanguageChoiceTexts.label(choice)
	hint_label.text = Texts.t(&"settingsLanguageAutomaticHint")
	accessibility_name = name_label.text


## Marks the row as the one picked: a check mark and the name in cyan.
func set_selected(selected: bool) -> void:
	check.visible = selected
	if selected:
		name_label.add_theme_color_override(&"font_color", AbyssColors.BIOLUM_CYAN)
	else:
		name_label.remove_theme_color_override(&"font_color")
