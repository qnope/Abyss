class_name SettingsRow
extends Button
## A row of a settings list that opens something, the whole row a touch area:
## its title and a chevron (Flutter's ListTile with an onTap, in
## lib/presentation/widgets/common/guide_settings.dart).

const HEIGHT := 48.0
const GAP := 8

var title_label := Label.new()
var chevron := UiIcon.glyph(&"chevron_right", 24.0, AbyssColors.ON_SURFACE_DIM)


func _init(title: String) -> void:
	theme_type_variation = AbyssSurfaceTheme.TAP
	custom_minimum_size.y = HEIGHT
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override(&"separation", GAP)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_label.theme_type_variation = &"TitleMedium"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(title_label)
	row.add_child(chevron)
	add_child(row)
	set_title(title)


## Writes the title of the row.
func set_title(title: String) -> void:
	title_label.text = title
	accessibility_name = title
