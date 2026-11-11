class_name UnitQuantityRow
extends RefreshingPanel
## How many units of a type to take out of a stock: the picture, the name in
## the unit's colour, what is in stock, a minus and a plus with the quantity
## between, and a slider under them
## (lib/presentation/widgets/fight/unit_quantity_row.dart). It keeps the
## quantity and tells each change with [signal changed].

## The quantity became [param value], from 0 to the stock.
signal changed(value: int)

const PORTRAIT_SIZE := 40.0
const GAP := 12
const VALUE_WIDTH := 28.0
const ICON_SIZE := 24
const SLIDER_MARGIN := 12

var type: UnitType.Value
var stock: int
var value := 0
var name_label := Label.new()
var stock_label := Label.new()
var value_label := Label.new()
var minus_button := Button.new()
var plus_button := Button.new()
var slider := HSlider.new()
var _minus_icon := UiIcon.glyph(&"remove", ICON_SIZE, AbyssColors.ON_SURFACE)
var _plus_icon := UiIcon.glyph(&"add", ICON_SIZE, AbyssColors.ON_SURFACE)


func _init(type_: UnitType.Value, stock_: int, value_ := 0) -> void:
	super()
	type = type_
	stock = stock_
	name_label.theme_type_variation = &"TitleMedium"
	name_label.add_theme_color_override(&"font_color", UnitColors.of(type))
	stock_label.theme_type_variation = &"BodySmall"
	stock_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	value_label.theme_type_variation = &"TitleMedium"
	value_label.custom_minimum_size.x = VALUE_WIDTH
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var texts := VBoxContainer.new()
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texts.alignment = BoxContainer.ALIGNMENT_CENTER
	texts.add_child(name_label)
	texts.add_child(stock_label)
	_arrange(minus_button, _minus_icon)
	_arrange(plus_button, _plus_icon)
	minus_button.pressed.connect(set_value.bind(-1, true))
	plus_button.pressed.connect(set_value.bind(1, true))
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	row.add_child(UnitPortrait.of(type, PORTRAIT_SIZE))
	for part: Control in [texts, minus_button, value_label, plus_button]:
		row.add_child(part)
	slider.max_value = stock
	slider.step = 1
	slider.value_changed.connect(func(next: float) -> void: set_value(int(next)))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override(&"margin_left", SLIDER_MARGIN)
	margin.add_theme_constant_override(&"margin_right", SLIDER_MARGIN)
	margin.add_child(slider)
	var column := VBoxContainer.new()
	column.add_child(row)
	column.add_child(margin)
	add_child(column)
	set_value(value_)
	refresh()


## Takes [param next] units, within the stock; with [param by_step] it is a
## step added to the quantity. The change is told when there is one.
func set_value(next: int, by_step := false) -> void:
	var taken := clampi(value + next if by_step else next, 0, stock)
	var moved := taken != value
	value = taken
	slider.set_value_no_signal(value)
	value_label.text = str(value)
	minus_button.disabled = value <= 0
	plus_button.disabled = value >= stock
	_minus_icon.self_modulate = AbyssColors.DISABLED if minus_button.disabled else AbyssColors.ON_SURFACE
	_plus_icon.self_modulate = AbyssColors.DISABLED if plus_button.disabled else AbyssColors.ON_SURFACE
	if moved:
		changed.emit(value)


func refresh() -> void:
	name_label.text = UnitTexts.display_name(type)
	stock_label.text = Texts.t(&"fightStock", {"count": stock})


## A button of the size of a touch with [param icon] at its centre.
func _arrange(button: Button, icon: UiIcon) -> void:
	button.theme_type_variation = &"TextButton"
	button.custom_minimum_size = Vector2.ONE * AbyssHudTheme.TOUCH_SIZE
	icon.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	button.add_child(icon)
