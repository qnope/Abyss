class_name DegradedBadge
extends RefreshingPanel
## "Dégradé": the marker of a building whose headquarters requirement is no
## longer met. Detailed, it also says which level is missing and what the
## building suffers (lib/presentation/widgets/building/degraded_badge.dart;
## [DegradedNotice] makes the detailed one of a building).

const GAP := 4
const ICON_SIZE := 14.0

var required_headquarters: int
var type: BuildingType.Value
var detailed: bool
var label := Label.new()
var effect_label := Label.new()


## The badge of the building [param type], degraded for want of the
## headquarters at [param required_headquarters]. [param detailed] adds the
## reason and the effect.
func _init(required_headquarters_: int, type_: BuildingType.Value, detailed_ := false) -> void:
	super()
	required_headquarters = required_headquarters_
	type = type_
	detailed = detailed_
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.theme_type_variation = &"BodySmall"
	label.add_theme_color_override(&"font_color", AbyssColors.WARNING)
	effect_label.theme_type_variation = &"BodySmall"
	effect_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	effect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	effect_label.visible = detailed
	var line := HBoxContainer.new()
	line.alignment = BoxContainer.ALIGNMENT_CENTER
	line.add_theme_constant_override(&"separation", GAP)
	line.add_child(UiIcon.glyph(&"warning", ICON_SIZE, AbyssColors.WARNING))
	line.add_child(label)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", GAP)
	column.add_child(line)
	column.add_child(effect_label)
	add_child(column)
	refresh()


func refresh() -> void:
	if detailed:
		label.text = Texts.t(&"buildingDegradedReason", {"level": required_headquarters})
		effect_label.text = BuildingDegradationTexts.degraded_effect(type)
	else:
		label.text = Texts.t(&"buildingDegraded")
