class_name ResourceAmountStrip
extends HFlowContainer
## A compact line of resource icons, each followed by its amount, wrapping
## onto a new line rather than overflowing a narrow box
## (lib/presentation/widgets/resource/resource_amount_strip.dart).

const SPACING := 10
const LINE_SPACING := 2
const ICON_GAP := 3

var amounts: Dictionary[ResourceType.Value, int]


## [param amounts] in the order given, the icons [param icon_size] points
## across.
func _init(amounts_: Dictionary[ResourceType.Value, int], icon_size := 15.0) -> void:
	amounts = amounts_
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override(&"h_separation", SPACING)
	add_theme_constant_override(&"v_separation", LINE_SPACING)
	for type: ResourceType.Value in amounts:
		var item := HBoxContainer.new()
		item.add_theme_constant_override(&"separation", ICON_GAP)
		item.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var amount := Label.new()
		amount.text = str(amounts[type])
		amount.theme_type_variation = &"BodySmall"
		amount.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE)
		amount.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item.add_child(ResourceIcon.new(type, icon_size))
		item.add_child(amount)
		add_child(item)
