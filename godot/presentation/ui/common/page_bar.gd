class_name PageBar
extends PanelContainer
## The app bar of a page (Flutter's AppBar): a back arrow at the left and a
## centred title, as high as a finger needs. A touch on the arrow tells
## [signal back_pressed]. The arrow's name follows the language by itself.

signal back_pressed

## The size of the back arrow, in points.
const ARROW_SIZE := 24.0

var back_button := Button.new()
var _title := Label.new()


func _init(title_text := "") -> void:
	theme_type_variation = &"AppBarPanel"
	auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	var row := HBoxContainer.new()
	var touch := Vector2(AbyssHudTheme.TOUCH_SIZE, AbyssHudTheme.TOUCH_SIZE)
	back_button.theme_type_variation = &"TextButton"
	back_button.custom_minimum_size = touch
	var arrow := UiIcon.glyph(&"arrow_back", ARROW_SIZE, AbyssColors.BIOLUM_CYAN)
	arrow.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	back_button.add_child(arrow)
	back_button.pressed.connect(back_pressed.emit)
	_title.theme_type_variation = &"AppBarTitle"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var balance := Control.new()
	balance.custom_minimum_size = touch
	row.add_child(back_button)
	row.add_child(_title)
	row.add_child(balance)
	add_child(row)
	set_title(title_text)
	_name_the_arrow()


## Writes the title.
func set_title(text: String) -> void:
	_title.text = text


func title() -> String:
	return _title.text


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_name_the_arrow()


func _name_the_arrow() -> void:
	var close_text := Texts.t(&"commonClose")
	back_button.tooltip_text = close_text
	back_button.accessibility_name = close_text
