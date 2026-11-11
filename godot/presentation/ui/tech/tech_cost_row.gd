class_name TechCostRow
extends HFlowContainer
## The costs of a research on one line, each a resource's icon and an amount,
## in red when the stock cannot pay it
## (lib/presentation/widgets/tech/tech_cost_row.dart).

const ICON_SIZE := 16.0
const GAP := 4
const ITEM_GAP := 12

## The amount of each cost, by resource.
var amounts: Dictionary[ResourceType.Value, Label] = {}


func _init(costs: Dictionary[ResourceType.Value, int],
		resources: Dictionary[ResourceType.Value, GameResource]) -> void:
	add_theme_constant_override(&"h_separation", ITEM_GAP)
	add_theme_constant_override(&"v_separation", GAP)
	for type: ResourceType.Value in costs:
		var label := Label.new()
		label.text = str(costs[type])
		label.theme_type_variation = &"LabelLarge"
		var affordable := GameResource.amount_in(resources, type) >= costs[type]
		label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE if affordable else AbyssColors.ERROR)
		var item := HBoxContainer.new()
		item.add_theme_constant_override(&"separation", GAP)
		item.add_child(ResourceIcon.new(type, ICON_SIZE))
		item.add_child(label)
		amounts[type] = label
		add_child(item)
