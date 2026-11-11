class_name ResourceBar
extends PanelContainer
## The strip of the five resources at the top of the game screen: algae,
## coral, ore and energy share the width, then a divider and the pearls, each
## an icon, an amount and its rate per turn; a touch on one opens its detail
## on the modal layer (lib/presentation/widgets/resource/resource_bar.dart).
## [method show_figures] gives it the figures of the next state: the amounts
## that changed flash and pop.

## The divider before the pearls, and the room it and the bar's right edge
## leave.
const DIVIDER_HEIGHT := 36.0
const DIVIDER_MARGIN := 4
const END_GAP := 8.0

## The item of each resource, in the order of the bar.
var items: Dictionary[ResourceType.Value, ResourceBarItem] = {}
var _modals: ModalLayer


## [param resources] with the [param production] and [param consumption]
## of the end of the turn; their detail opens on [param modals].
func _init(resources: Dictionary[ResourceType.Value, GameResource],
		production: Dictionary[ResourceType.Value, int],
		consumption: Dictionary[ResourceType.Value, int], modals: ModalLayer) -> void:
	_modals = modals
	theme_type_variation = AbyssHudTheme.RESOURCE_BAR
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 0)
	for type: ResourceType.Value in resources:
		if type == ResourceType.Value.PEARL:
			continue
		row.add_child(_item(resources[type], production, consumption))
	row.add_child(_divider())
	row.add_child(_item(resources[ResourceType.Value.PEARL], production, consumption))
	var end := Control.new()
	end.custom_minimum_size.x = END_GAP
	row.add_child(end)
	add_child(row)


## Shows the figures of the next state; an amount that changed flashes.
func show_figures(resources: Dictionary[ResourceType.Value, GameResource],
		production: Dictionary[ResourceType.Value, int],
		consumption: Dictionary[ResourceType.Value, int]) -> void:
	for type: ResourceType.Value in items:
		items[type].show_figures(resources[type], _of(production, type), _of(consumption, type))


## Whether the end of the turn spends more [param type] than the base makes.
func is_short(type: ResourceType.Value) -> bool:
	return items[type].is_short()


func _item(resource: GameResource, production: Dictionary[ResourceType.Value, int],
		consumption: Dictionary[ResourceType.Value, int]) -> ResourceBarItem:
	var item := ResourceBarItem.new(resource, _of(production, resource.type),
		_of(consumption, resource.type))
	item.pressed.connect(_open_detail.bind(item))
	items[resource.type] = item
	return item


func _open_detail(item: ResourceBarItem) -> void:
	_modals.open(ResourceDetailSheet.new(item.resource, item.production))


## The figure of [param type], 0 when the turn has none.
static func _of(figures: Dictionary[ResourceType.Value, int], type: ResourceType.Value) -> int:
	return figures.get(type, 0)


static func _divider() -> Control:
	var divider := VSeparator.new()
	divider.custom_minimum_size.y = DIVIDER_HEIGHT
	divider.add_theme_constant_override(&"separation", 1 + 2 * DIVIDER_MARGIN)
	return divider
