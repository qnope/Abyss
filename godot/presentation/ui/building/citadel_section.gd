class_name CitadelSection
extends VBoxContainer
## What the Coral Citadel gives the base: the rampart it raises now, the next
## one, and how it fights in a raid
## (lib/presentation/widgets/building/coral_citadel_info_section.dart).

const GAP := 4
const HINT_GAP := 6
const ICON_SIZE := 16.0

var current_label := Label.new()
var next_label := Label.new()
var hint_label := Label.new()


func _init(building: Building) -> void:
	var level := building.level
	var is_max := level >= BuildingCostCalculator.new().max_level(building.type)
	add_theme_constant_override(&"separation", GAP)
	current_label.text = Texts.t(&"baseRampartCurrent", {"rampart": RampartTexts.coral(level)})
	current_label.add_theme_color_override(&"font_color",
		AbyssColors.DISABLED if level == 0 else AbyssColors.ON_SURFACE)
	next_label.text = Texts.t(&"baseRampartMax") if is_max else Texts.t(
		&"baseRampartNext", {"rampart": RampartTexts.coral(level + 1)})
	hint_label.text = Texts.t(&"baseRampartHint")
	hint_label.theme_type_variation = &"BodySmall"
	hint_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var hint := HBoxContainer.new()
	hint.add_theme_constant_override(&"separation", HINT_GAP)
	var icon := UiIcon.glyph(&"fort", ICON_SIZE, AbyssColors.ON_SURFACE_DIM)
	icon.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	hint.add_child(icon)
	hint.add_child(hint_label)
	for each: Label in [current_label, next_label]:
		each.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		add_child(each)
	add_child(hint)
