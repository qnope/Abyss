class_name RecruitmentSection
extends VBoxContainer
## What the sheet of an unit offers to recruit: how many (a slider up to what
## the stock pays for), what it costs in each resource, the noise it makes and
## the button that recruits (lib/presentation/widgets/unit/recruitment_section.dart).
## Once the type was recruited this turn a line says so, and while the stock
## pays for none, another. It tells [signal recruit_pressed] with the quantity
## and leaves the recruiting to its owner. Built from a [UnitView]; the sheet
## builds it again on each change.

## The player pressed the button, for [param quantity] units (1 or more).
signal recruit_pressed(quantity: int)

const GAP := 8
const ROW_GAP := 4
const ICON_SIZE := 16.0

var view: UnitView
var quantity := 0
var slider: HSlider
var quantity_label: Label
var noise_row: NoiseCostRow
var button: Button
## The amount of each resource the quantity costs.
var cost_labels: Dictionary[ResourceType.Value, Label] = {}


func _init(view_: UnitView) -> void:
	view = view_
	add_theme_constant_override(&"separation", ROW_GAP)
	if view.recruited_this_turn:
		_say(&"unitRecruitDone", AbyssColors.WARNING)
		return
	if view.max_recruitable() == 0:
		_say(&"unitNotEnoughResources", AbyssColors.DISABLED)
		return
	slider = HSlider.new()
	slider.min_value = 0
	slider.max_value = view.max_recruitable()
	slider.step = 1
	slider.value_changed.connect(set_quantity)
	add_child(slider)
	quantity_label = Label.new()
	add_child(quantity_label)
	var gap := Control.new()
	gap.custom_minimum_size.y = GAP - ROW_GAP
	add_child(gap)
	var costs := view.unit_cost()
	for type: ResourceType.Value in costs:
		add_child(_cost_row(type))
	noise_row = NoiseCostRow.new(0)
	add_child(noise_row)
	button = Button.new()
	button.text = Texts.t(&"unitRecruit")
	button.pressed.connect(func() -> void: recruit_pressed.emit(quantity))
	add_child(button)
	set_quantity(0)


## Recruits [param next] units: the slider, the totals, the noise and the
## button follow it.
func set_quantity(next: float) -> void:
	quantity = int(next)
	slider.set_value_no_signal(quantity)
	quantity_label.text = Texts.t(&"unitTotalCount", {"count": quantity})
	var costs := view.unit_cost()
	for type: ResourceType.Value in costs:
		cost_labels[type].text = str(costs[type] * quantity)
	noise_row.set_noise(NoiseRules.PER_RECRUIT * quantity)
	button.disabled = quantity == 0


func _cost_row(type: ResourceType.Value) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	var amount := Label.new()
	amount.add_theme_color_override(&"font_color", ResourceColors.of(type))
	cost_labels[type] = amount
	row.add_child(ResourceIcon.new(type, ICON_SIZE))
	row.add_child(amount)
	return row


## A line of text in place of the controls, when there is nothing to pick.
func _say(key: StringName, color: Color) -> void:
	var line := Label.new()
	line.text = Texts.t(key)
	line.add_theme_color_override(&"font_color", color)
	add_child(line)
