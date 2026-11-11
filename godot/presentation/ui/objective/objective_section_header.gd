class_name ObjectiveSectionHeader
extends VBoxContainer
## The header of a section of the objectives sheet (lib/.../
## objective_section_header.dart): its title, then the line of lore of its
## chapter when it has one.

const TOP := 12
const GAP := 2

var title_label := Label.new()
var lore_label: LoreText


func _init(title: String, lore := "") -> void:
	add_theme_constant_override(&"separation", GAP)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var space := Control.new()
	space.custom_minimum_size.y = TOP - GAP
	add_child(space)
	title_label.text = title
	title_label.theme_type_variation = &"TitleSmall"
	add_child(title_label)
	if not lore.is_empty():
		lore_label = LoreText.new(lore, HORIZONTAL_ALIGNMENT_LEFT, LoreText.SMALL)
		add_child(lore_label)
