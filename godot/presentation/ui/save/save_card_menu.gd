class_name SaveCardMenu
extends Button
## The "more" options of a save card
## (lib/presentation/widgets/save/save_card_menu.dart): a button that opens a
## small menu with one entry, delete. Its touch stays its own: it never opens
## the game the card stands for.

## The player chose to delete the game.
signal delete_requested

const ICON_SIZE := 20.0
const DELETE_ID := 1

var popup := PopupMenu.new()


func _init() -> void:
	theme_type_variation = &"TextButton"
	custom_minimum_size = Vector2(AbyssHudTheme.TOUCH_SIZE, AbyssHudTheme.TOUCH_SIZE)
	var dots := UiIcon.glyph(&"more_vert", ICON_SIZE, AbyssColors.ON_SURFACE_DIM)
	dots.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(dots)
	popup.add_theme_color_override(&"font_color", AbyssColors.ERROR)
	popup.add_theme_color_override(&"font_hover_color", AbyssColors.ERROR)
	popup.add_icon_item(load(UiIcon.glyph_path(&"delete_outline")) as Texture2D, "", DELETE_ID)
	popup.set_item_icon_modulate(0, AbyssColors.ERROR)
	popup.id_pressed.connect(_on_chosen)
	add_child(popup)
	pressed.connect(_open)
	# Last: it tells the node, which writes the texts the menu holds by then.
	auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_write()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_write()


## Opens the menu under the button, its right edge on the button's.
func _open() -> void:
	popup.reset_size()
	var anchor := get_global_rect()
	var place := Vector2i(anchor.end - Vector2(popup.size.x, 0.0))
	popup.popup_on_parent(Rect2i(Vector2i(place.x, int(anchor.end.y)), Vector2i.ZERO))


func _on_chosen(_id: int) -> void:
	delete_requested.emit()


func _write() -> void:
	var options := Texts.t(&"saveOptions")
	tooltip_text = options
	accessibility_name = options
	popup.set_item_text(0, Texts.t(&"saveDelete"))
