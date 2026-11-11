extends UiTestCase
## The options of a save card: a button that opens a menu with "delete".

var _deleted := 0


func test_opens_a_menu_with_the_delete_entry() -> void:
	var menu := _menu()
	assert_eq(menu.popup.item_count, 1)
	assert_eq(menu.popup.get_item_text(0), "Supprimer")
	assert_eq(menu.popup.get_item_id(0), SaveCardMenu.DELETE_ID)
	assert_eq(menu.popup.get_item_icon_modulate(0), AbyssColors.ERROR)
	assert_eq(menu.popup.get_theme_color(&"font_color"), AbyssColors.ERROR)
	press(menu)
	assert_true(menu.popup.visible)
	menu.popup.hide()


func test_choosing_delete_tells_it() -> void:
	var menu := _menu()
	menu.popup.id_pressed.emit(SaveCardMenu.DELETE_ID)
	assert_eq(_deleted, 1)


func test_is_a_touch_sized_button_named_options() -> void:
	var menu := _menu()
	assert_true(menu.custom_minimum_size.x >= AbyssHudTheme.TOUCH_SIZE)
	assert_eq(menu.tooltip_text, "Options")
	assert_eq((menu.get_child(0) as UiIcon).icon_path, UiIcon.glyph_path(&"more_vert"))


func test_follows_the_language() -> void:
	var menu := _menu()
	use_language("en")
	assert_eq(menu.tooltip_text, "Options")
	assert_eq(menu.popup.get_item_text(0), "Delete")
	use_language("es")
	assert_eq(menu.popup.get_item_text(0), "Eliminar")


func _menu() -> SaveCardMenu:
	var menu := mount(SaveCardMenu.new()) as SaveCardMenu
	menu.delete_requested.connect(func() -> void: _deleted += 1)
	return menu
