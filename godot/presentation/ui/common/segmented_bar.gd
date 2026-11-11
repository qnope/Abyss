class_name SegmentedBar
extends PanelContainer
## A tray of segments sharing its width, one of them lit; a touch on one
## tells its value ([signal chosen]) and lights it (lib/.../segmented_bar.dart,
## look in AbyssSegmentedTheme). The segments are the buttons of one
## ButtonGroup, so they are one choice among several for the keyboard and
## screen readers. A label too wide for its segment is cut with an ellipsis,
## where Flutter's shrinks it to fit.
##
## It keeps its own selection: a touch lights the segment at once, and
## [method select] sets it from outside without a signal.

## A segment was touched, even the lit one: [param value] is its value.
signal chosen(value: Variant)

var _values: Array = []
var _buttons: Array[Button] = []
var _names: Array[Label] = []
var _details: Array[Label] = []


func _init(items: Array[SegmentItem], selected: Variant) -> void:
	theme_type_variation = &"SegmentedTray"
	custom_minimum_size.y = AbyssSegmentedTheme.HEIGHT
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 0)
	var group := ButtonGroup.new()
	for item in items:
		var button := _segment(item, group)
		row.add_child(button)
		_buttons.append(button)
		_values.append(item.value)
	add_child(row)
	select(selected)


## Lights the segment of [param value] without telling it; a value no
## segment has changes nothing.
func select(value: Variant) -> void:
	var index := _values.find(value)
	if index < 0:
		return
	for at in _buttons.size():
		_buttons[at].set_pressed_no_signal(at == index)
		_paint(at == index, at)


## The value of the lit segment, or null when none is.
func selected() -> Variant:
	for at in _buttons.size():
		if _buttons[at].button_pressed:
			return _values[at]
	return null


## The button of the segment of [param value].
func button(value: Variant) -> Button:
	return _buttons[_values.find(value)]


## The label with the name of the segment of [param value].
func name_label(value: Variant) -> Label:
	return _names[_values.find(value)]


## The label with the detail of the segment of [param value], null if none.
func detail_label(value: Variant) -> Label:
	return _details[_values.find(value)]


func _segment(item: SegmentItem, group: ButtonGroup) -> Button:
	var button := Button.new()
	button.theme_type_variation = AbyssSegmentedTheme.SEGMENT
	button.toggle_mode = true
	button.button_group = group
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.accessibility_name = item.semantics_label
	var lines := VBoxContainer.new()
	lines.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lines.alignment = BoxContainer.ALIGNMENT_CENTER
	lines.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lines.add_theme_constant_override(&"separation", 0)
	_names.append(_line(&"SegmentName", item.label, lines))
	_details.append(_line(&"SegmentDetail", item.detail, lines) if item.detail != "" else null)
	button.add_child(lines)
	var at := _buttons.size()
	button.toggled.connect(func(on: bool) -> void: _paint(on, at))
	button.pressed.connect(func() -> void: chosen.emit(item.value))
	return button


func _line(variation: StringName, text: String, into: Control) -> Label:
	var label := Label.new()
	label.text = text
	label.theme_type_variation = variation
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	into.add_child(label)
	return label


## Turns the texts of segment [param at] to the ink of a lit segment, or back
## to their own: a Label does not follow its button's state.
func _paint(on: bool, at: int) -> void:
	var lines: Array[Label] = [_names[at]]
	if _details[at] != null:
		lines.append(_details[at])
	for line in lines:
		if on:
			line.add_theme_color_override(&"font_color", AbyssSegmentedTheme.ON_SELECTED)
		else:
			line.remove_theme_color_override(&"font_color")
