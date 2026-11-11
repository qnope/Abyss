class_name ResourceGainsRow
extends HFlowContainer
## An inline list of resource gains, each as its icon and "+N" in the colour
## of the resource; what is not gained is left out
## (lib/presentation/widgets/resource/resource_gains_row.dart).

const SPACING := 12
const LINE_SPACING := 4
const ICON_SIZE := 14.0
const ICON_GAP := 4


func _init(gains: Dictionary[ResourceType.Value, int]) -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override(&"h_separation", SPACING)
	add_theme_constant_override(&"v_separation", LINE_SPACING)
	for type: ResourceType.Value in gains:
		if gains[type] <= 0:
			continue
		var item := HBoxContainer.new()
		item.add_theme_constant_override(&"separation", ICON_GAP)
		item.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var amount := Label.new()
		amount.text = "+%d" % gains[type]
		amount.theme_type_variation = &"BodySmall"
		amount.add_theme_color_override(&"font_color", ResourceColors.of(type))
		item.add_child(ResourceIcon.new(type, ICON_SIZE))
		item.add_child(amount)
		add_child(item)
