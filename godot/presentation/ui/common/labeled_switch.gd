class_name LabeledSwitch
extends PanelContainer
## A switch with its title and a one-line subtitle explaining it, the whole
## row tappable (lib/.../labeled_switch.dart, Flutter's SwitchListTile).
## [signal toggled] tells the new value when the player touches the row; the
## switch has moved by then. [method set_value] sets it from outside without
## a signal.

signal toggled(on: bool)

const GAP := 16

var title_label := Label.new()
var subtitle_label := Label.new()
var switch := CheckButton.new()


func _init(title: String, subtitle: String, value: bool) -> void:
	theme_type_variation = AbyssSurfaceTheme.BARE
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	var lines := VBoxContainer.new()
	lines.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lines.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_label.text = title
	title_label.theme_type_variation = &"TitleMedium"
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	subtitle_label.text = subtitle
	subtitle_label.theme_type_variation = &"BodySmall"
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	switch.theme_type_variation = &"Switch"
	switch.button_pressed = value
	switch.accessibility_name = title
	switch.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	switch.toggled.connect(toggled.emit)
	lines.add_child(title_label)
	lines.add_child(subtitle_label)
	row.add_child(lines)
	row.add_child(switch)
	add_child(row)
	gui_input.connect(_on_gui_input)


## Moves the switch to [param value] without telling it.
func set_value(value: bool) -> void:
	switch.set_pressed_no_signal(value)


func value() -> bool:
	return switch.button_pressed


func _on_gui_input(event: InputEvent) -> void:
	var touch := event as InputEventMouseButton
	if touch != null and touch.pressed and touch.button_index == MOUSE_BUTTON_LEFT:
		switch.button_pressed = not switch.button_pressed
