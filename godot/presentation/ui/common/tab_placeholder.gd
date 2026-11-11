class_name TabPlaceholder
extends RefreshingPanel
## What a tab still to come shows, in the middle of its area: an icon, the
## tab's name and "coming soon" (lib/.../tab_placeholder.dart). The tab's
## name is the caller's; "coming soon" follows the language.

const ICON_SIZE := 64.0
const GAP := 8

var name_label := Label.new()
var soon_label := Label.new()


## A placeholder for the tab called [param tab_name], with the icon in the
## file [param icon_path].
func _init(icon_path: String, tab_name: String) -> void:
	super()
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	column.add_theme_constant_override(&"separation", GAP)
	var icon := UiIcon.new(icon_path, ICON_SIZE, Color(AbyssColors.BIOLUM_CYAN, 0.5))
	name_label.text = tab_name
	name_label.theme_type_variation = &"HeadlineSmall"
	name_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	soon_label.add_theme_color_override(&"font_color", AbyssColors.DISABLED)
	soon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(icon)
	column.add_child(name_label)
	column.add_child(soon_label)
	add_child(column)
	refresh()


func refresh() -> void:
	soon_label.text = Texts.t(&"screenComingSoon")
