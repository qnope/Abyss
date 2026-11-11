class_name ChipRow
extends ScrollContainer
## A horizontal row of chips, one of them lit, that scrolls sideways when it is
## wider than the screen (Flutter's row of ChoiceChips in a horizontal
## SingleChildScrollView, lib/.../history_filter_chips.dart). A chip is a
## button of the theme: the lit one filled, the others outlined. A touch on a
## chip tells [signal chosen] unless it is the lit one already.

## A chip other than the lit one was touched: [param value] is its value.
signal chosen(value: Variant)

const GAP := 8

var _values: Array = []
var _buttons: Array[Button] = []
var _selected: Variant


## The chips of [param items] (a [SegmentItem] each: value and label), with the
## one of [param selected] lit.
func _init(items: Array[SegmentItem], selected: Variant) -> void:
	vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	for item in items:
		var button := Button.new()
		button.text = item.label
		button.accessibility_name = item.semantics_label
		button.pressed.connect(_touched.bind(item.value))
		_values.append(item.value)
		_buttons.append(button)
		row.add_child(button)
	add_child(row)
	select(selected)


## Lights the chip of [param value] without telling it.
func select(value: Variant) -> void:
	_selected = value
	for at in _buttons.size():
		_buttons[at].theme_type_variation = &"" if _values[at] == value else &"OutlinedButton"


## The value of the lit chip.
func selected() -> Variant:
	return _selected


## The button of the chip of [param value].
func button(value: Variant) -> Button:
	return _buttons[_values.find(value)]


func _touched(value: Variant) -> void:
	if value == _selected:
		return
	select(value)
	chosen.emit(value)
