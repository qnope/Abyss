class_name QualityPanel
extends PanelContainer
## A small panel to compare the scene's costs live on a phone: shadows,
## glow and particles on or off, the 3D render scale, and a frame rate
## capped when nothing moves. Folded under its title until opened, its
## buttons sized for a finger. It only tells what the player chose
## (changed); the app applies it.

## The player turned [param setting] to [param value]: a bool, or the
## render scale as a float.
signal changed(setting: StringName, value: Variant)

const SHADOWS := &"shadows"
const GLOW := &"glow"
const PARTICLES := &"particles"
const IDLE_CAP := &"idle_cap"
const SCALE := &"scale"
## The render scales offered, the full resolution first.
const SCALES: Array[float] = [1.0, 0.75, 0.5]
const SWITCHES: Dictionary[StringName, String] = {
	SHADOWS: "Ombres", GLOW: "Lueur", PARTICLES: "Particules", IDLE_CAP: "30 i/s au repos",
}

var _title := Button.new()
var _body := VBoxContainer.new()
var _switches: Dictionary[StringName, Button] = {}
var _scales: Array[Button] = []


func _init() -> void:
	theme_type_variation = AbyssHudTheme.PANEL
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", AbyssHudTheme.GAP)
	_title.text = "Qualité"
	_title.theme_type_variation = &"TextButton"
	_title.custom_minimum_size = Vector2(AbyssHudTheme.TOUCH_SIZE, AbyssHudTheme.TOUCH_SIZE)
	_title.focus_mode = FOCUS_NONE
	_title.pressed.connect(func() -> void: _body.visible = not _body.visible)
	column.add_child(_title)
	_body.add_theme_constant_override(&"separation", AbyssHudTheme.GAP)
	_body.visible = false
	column.add_child(_body)
	for setting in SWITCHES:
		var button := _toggle(SWITCHES[setting])
		button.button_pressed = true
		button.toggled.connect(func(on: bool) -> void: changed.emit(setting, on))
		_switches[setting] = button
	_body.add_child(_tray([_switches[SHADOWS], _switches[GLOW], _switches[PARTICLES]]))
	var group := ButtonGroup.new()
	for scale in SCALES:
		var button := _toggle("×%s" % scale)
		button.button_group = group
		button.toggled.connect(func(on: bool) -> void: if on: changed.emit(SCALE, scale))
		_scales.append(button)
	_scales[0].button_pressed = true
	_body.add_child(_tray(_scales))
	_body.add_child(_tray([_switches[IDLE_CAP]]))
	add_child(column)


func expand() -> void:
	_body.visible = true


func collapse() -> void:
	_body.visible = false


func is_expanded() -> bool:
	return _body.visible


## Shows [param setting] as [param value] without telling it: the state
## the app starts with.
func show_value(setting: StringName, value: Variant) -> void:
	if setting == SCALE:
		_scales[SCALES.find(value)].set_pressed_no_signal(true)
	else:
		var on: bool = value
		_switches[setting].set_pressed_no_signal(on)


## The button of [param setting] (a switch), or of the render scale
## [param scale].
func button(setting: StringName, scale := 1.0) -> Button:
	return _scales[SCALES.find(scale)] if setting == SCALE else _switches[setting]


static func _toggle(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.toggle_mode = true
	button.theme_type_variation = AbyssHudTheme.TOGGLE
	button.custom_minimum_size = Vector2(AbyssHudTheme.TOUCH_SIZE, AbyssHudTheme.TOUCH_SIZE)
	button.size_flags_horizontal = SIZE_EXPAND_FILL
	button.focus_mode = FOCUS_NONE
	return button


static func _tray(buttons: Array[Button]) -> PanelContainer:
	var row := HBoxContainer.new()
	for button in buttons:
		row.add_child(button)
	var tray := PanelContainer.new()
	tray.theme_type_variation = &"SegmentedTray"
	tray.add_child(row)
	return tray
