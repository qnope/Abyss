class_name BuildingHeader
extends VBoxContainer
## The top of a building's sheet: its picture, its name in its colour and its
## level, or that it is still to build.

const PORTRAIT_SIZE := 64.0
const GAP := 4

var portrait: Portrait
var name_label := Label.new()
var level_label := Label.new()


func _init(building: Building) -> void:
	var color := BuildingColors.of(building.type)
	var title := BuildingTexts.display_name(building.type)
	add_theme_constant_override(&"separation", GAP)
	portrait = Portrait.new(title, PORTRAIT_SIZE, color if building.level > 0 else AbyssColors.DISABLED)
	name_label.text = title
	name_label.theme_type_variation = &"HeadlineSmall"
	name_label.add_theme_color_override(&"font_color", color)
	level_label.text = Texts.t(&"baseLevel", {"level": building.level}) if building.level > 0 \
		else Texts.t(&"baseNotBuilt")
	add_child(portrait)
	for each: Label in [name_label, level_label]:
		each.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(each)
