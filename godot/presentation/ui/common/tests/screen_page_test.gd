extends UiTestCase
## The page of a screen: an app bar with a back arrow and a title that follows
## the language, over a body, on a veil.

var _backs := 0


func test_shows_its_title_in_the_app_bar_over_a_veil() -> void:
	var page := _page()
	assert_eq(page.bar.title(), "Charger une partie")
	assert_eq(page.bar.theme_type_variation, &"AppBarPanel")
	var veil := page.get_child(0) as Panel
	assert_eq(veil.theme_type_variation, AbyssSurfaceTheme.VEIL)
	assert_eq(veil.mouse_filter, Control.MOUSE_FILTER_IGNORE, "touches go through the veil")
	assert_eq(page.body.theme_type_variation, AbyssSurfaceTheme.BARE)
	assert_eq(page.body.size_flags_vertical, Control.SIZE_EXPAND_FILL)


func test_an_undimmed_page_has_no_veil() -> void:
	var page := mount(ScreenPage.new(&"saveLoadTitle", false)) as ScreenPage
	assert_eq(page.get_child_count(), 1)
	assert_false(page.get_child(0) is Panel)


func test_follows_the_language() -> void:
	var page := _page()
	use_language("en")
	assert_eq(page.bar.title(), "Load a game")
	assert_eq(page.bar.back_button.tooltip_text, "Close")
	assert_no_raw_keys()


func test_the_arrow_tells_back() -> void:
	var page := _page()
	assert_eq(page.bar.back_button.accessibility_name, "Fermer")
	press(page.bar.back_button)
	assert_eq(_backs, 1)


func test_escape_tells_back_when_the_page_shows() -> void:
	var page := _page()
	var event := InputEventAction.new()
	event.action = &"ui_cancel"
	event.pressed = true
	page._unhandled_input(event)
	assert_eq(_backs, 1)
	page._unhandled_input(InputEventKey.new())
	assert_eq(_backs, 1, "another event does nothing")
	page.hide()
	page._unhandled_input(event)
	assert_eq(_backs, 1, "a page that is hidden does not answer")


func _page() -> ScreenPage:
	var page := mount(ScreenPage.new(&"saveLoadTitle")) as ScreenPage
	page.back_pressed.connect(func() -> void: _backs += 1)
	return page
