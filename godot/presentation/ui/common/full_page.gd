class_name FullPage
extends ModalPanel
## A page over the whole screen (Flutter's Scaffold with an AppBar, pushed as
## a route): an app bar with a back button at the left and a centred title,
## and a body that scrolls. The back button ends the page with a null result.
## Fill [member body] with the content.

## The size of the back arrow, in points.
const ARROW_SIZE := 24.0

## The content, under the app bar, padded.
var body: VBoxContainer
var back_button := Button.new()
var _title := Label.new()
var _scroll := ScrollBody.new()


func _init(title_text := "") -> void:
	super()
	placement = Placement.FULL
	theme_type_variation = AbyssSurfaceTheme.PAGE
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 0)
	column.add_child(_app_bar())
	# Taller than the room, the body scrolls: it does not push the page.
	_scroll.max_height = 0.0
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_scroll)
	add_child(column)
	var padding := MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]:
		padding.add_theme_constant_override("margin_" + side, AbyssCardTheme.GAP)
	body = VBoxContainer.new()
	padding.add_child(body)
	_scroll.content.add_child(padding)
	set_title(title_text)
	refresh()


## Writes the title in the app bar.
func set_title(text: String) -> void:
	_title.text = text


func title() -> String:
	return _title.text


func refresh() -> void:
	var close_text := Texts.t(&"commonClose")
	back_button.tooltip_text = close_text
	back_button.accessibility_name = close_text


func _app_bar() -> PanelContainer:
	var bar := PanelContainer.new()
	bar.theme_type_variation = &"AppBarPanel"
	var row := HBoxContainer.new()
	var touch := Vector2(AbyssHudTheme.TOUCH_SIZE, AbyssHudTheme.TOUCH_SIZE)
	back_button.theme_type_variation = &"TextButton"
	back_button.custom_minimum_size = touch
	var arrow := UiIcon.glyph(&"arrow_back", ARROW_SIZE, AbyssColors.BIOLUM_CYAN)
	arrow.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	back_button.add_child(arrow)
	back_button.pressed.connect(close)
	_title.theme_type_variation = &"AppBarTitle"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var balance := Control.new()
	balance.custom_minimum_size = touch
	row.add_child(back_button)
	row.add_child(_title)
	row.add_child(balance)
	bar.add_child(row)
	return bar
