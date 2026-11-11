class_name MenuSettingsButton
extends Button
## A discreet gear over the menu art, which opens the settings reachable
## outside a game (lib/presentation/widgets/menu/menu_settings_button.dart).
## Its name follows the language.

const ICON_SIZE := 24.0

func _init() -> void:
	theme_type_variation = &"TextButton"
	custom_minimum_size = Vector2(AbyssHudTheme.TOUCH_SIZE, AbyssHudTheme.TOUCH_SIZE)
	auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	var gear := UiIcon.glyph(&"settings", ICON_SIZE, AbyssMenuTheme.CORNER_ICON)
	gear.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(gear)
	_name_the_gear()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_name_the_gear()


func _name_the_gear() -> void:
	var settings := Texts.t(&"screenSettings")
	tooltip_text = settings
	accessibility_name = settings
