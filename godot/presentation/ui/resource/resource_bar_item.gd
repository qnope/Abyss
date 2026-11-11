class_name ResourceBarItem
extends Button
## One resource of the [ResourceBar]: its icon, its amount (which flashes and
## pops when it changes) and under it the rate per turn, "+8/t", or
## "+50/-12/t" when something is consumed, red when the consumption exceeds
## the production: the shortage
## (lib/presentation/widgets/resource/resource_bar_item.dart). The whole
## item is a touch area; it tells `pressed`.

const ICON_SIZE := 20.0
const ICON_GAP := 4
## The height of the rate line, kept when there is no rate so that the
## items are all as tall.
const RATE_HEIGHT := 16.0
const HEIGHT := 44.0
## How much of its colour the rate keeps when nothing is lacking.
const RATE_ALPHA := 0.7

var resource: GameResource
var production: int
var consumption: int
var amount_label: AnimatedAmount
var rate_label := Label.new()


func _init(resource_: GameResource, production_ := 0, consumption_ := 0) -> void:
	resource = resource_
	production = production_
	consumption = consumption_
	var color := ResourceColors.of(resource.type)
	theme_type_variation = AbyssSurfaceTheme.TAP
	custom_minimum_size.y = HEIGHT
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	amount_label = AnimatedAmount.new(color, resource.amount)
	var column := VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override(&"separation", 0)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var line := HBoxContainer.new()
	line.alignment = BoxContainer.ALIGNMENT_CENTER
	line.add_theme_constant_override(&"separation", ICON_GAP)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.add_child(ResourceIcon.new(resource.type, ICON_SIZE))
	line.add_child(amount_label)
	rate_label.theme_type_variation = &"ResourceRate"
	rate_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rate_label.custom_minimum_size.y = RATE_HEIGHT
	rate_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(line)
	column.add_child(rate_label)
	add_child(column)
	show_figures(resource, production, consumption)


## Shows [param resource_] with its [param production_] and
## [param consumption_] per turn; its amount flashes if it changed.
func show_figures(resource_: GameResource, production_: int, consumption_: int) -> void:
	resource = resource_
	production = production_
	consumption = consumption_
	amount_label.set_amount(resource.amount)
	rate_label.text = rate_text(production, consumption)
	var color := ResourceColors.of(resource.type)
	rate_label.add_theme_color_override(&"font_color",
		AbyssColors.ERROR if is_short() else Color(color, RATE_ALPHA))


## Whether the end of the turn spends more than the base makes of it.
func is_short() -> bool:
	return consumption > production


## "+8/t", "+50/-12/t", empty when there is neither.
static func rate_text(production_: int, consumption_: int) -> String:
	if production_ <= 0 and consumption_ <= 0:
		return ""
	if consumption_ > 0:
		return "+%d/-%d/t" % [production_, consumption_]
	return "+%d/t" % production_
