extends UiTestCase
## The dialog in the middle of the screen: a title, a body that scrolls, the
## actions at the right, each ending it with its result.

var _results: Array = []


func test_looks_like_the_theme_dialog_centred() -> void:
	var dialog := AbyssDialog.new("Hello")
	assert_eq(dialog.theme_type_variation, &"DialogPanel")
	assert_eq(dialog.placement, ModalPanel.Placement.CENTER)
	assert_true(dialog.dismissible)
	dialog.free()


func test_shows_its_title_in_the_dialog_style_unless_there_is_none() -> void:
	var dialog := mount(AbyssDialog.new("Settings")) as AbyssDialog
	var title := find_text("Settings") as Label
	assert_eq(title.theme_type_variation, &"DialogTitle")
	assert_eq(dialog.title(), "Settings")
	dialog.set_title("")
	assert_null(find_text("Settings"))
	dialog.set_title("Renamed")
	assert_not_null(find_text("Renamed"))
	var untitled := AbyssDialog.new()
	assert_eq(untitled.title(), "")
	untitled.free()


func test_holds_the_content_in_its_body() -> void:
	var dialog := mount(AbyssDialog.new()) as AbyssDialog
	var line := Label.new()
	line.text = "Are you sure?"
	dialog.body.add_child(line)
	assert_eq(find_text("Are you sure?", dialog), line)
	assert_true(dialog.body.get_parent() is ScrollBody)


func test_ends_with_the_result_of_the_action_pressed() -> void:
	var dialog := mount(AbyssDialog.new("Quit?")) as AbyssDialog
	dialog.closed.connect(func(result: Variant) -> void: _results.append(result))
	var cancel := dialog.add_action("Cancel")
	var quit := dialog.add_action("Quit", {"quit": true}, &"")
	assert_eq(dialog.actions(), [cancel, quit] as Array[Button])
	assert_eq(cancel.theme_type_variation, &"TextButton")
	assert_eq(quit.theme_type_variation, &"")
	press(quit)
	assert_eq(_results, [{"quit": true}])
	assert_true(dialog.is_closed())


func test_a_button_is_an_action_that_does_not_end_the_dialog() -> void:
	var dialog := mount(AbyssDialog.new()) as AbyssDialog
	dialog.closed.connect(func(result: Variant) -> void: _results.append(result))
	var copy := dialog.add_button("Copy")
	var close := dialog.add_action("Close")
	assert_eq(dialog.actions(), [copy, close] as Array[Button])
	assert_eq(copy.theme_type_variation, &"TextButton")
	assert_eq(dialog.add_button("Share", &"").theme_type_variation, &"")
	press(copy)
	assert_eq(_results, [] as Array)
	assert_false(dialog.is_closed())


func test_a_cancel_action_ends_with_null() -> void:
	var dialog := mount(AbyssDialog.new()) as AbyssDialog
	dialog.closed.connect(func(result: Variant) -> void: _results.append(result))
	dialog.add_action("Cancel")
	press("Cancel")
	assert_eq(_results, [null])


func test_is_as_wide_as_the_screen_less_its_margins_within_limits() -> void:
	assert_eq(AbyssDialog.width_in(Vector2(390.0, 844.0)), 310.0)
	assert_eq(AbyssDialog.width_in(Vector2(200.0, 844.0)), AbyssDialog.MIN_WIDTH)
	assert_eq(AbyssDialog.width_in(Vector2(1200.0, 700.0)), AbyssDialog.MAX_WIDTH)
	var dialog := AbyssDialog.new()
	dialog.fit(Vector2(390.0, 844.0))
	assert_eq(dialog.custom_minimum_size.x, 310.0)
	dialog.free()


func test_scrolls_its_body_when_it_is_taller_than_the_screen() -> void:
	var dialog := mount(AbyssDialog.new("Long")) as AbyssDialog
	var tall := Control.new()
	tall.custom_minimum_size.y = 2000.0
	dialog.body.add_child(tall)
	dialog.fit(Vector2(390.0, 800.0))
	var scroll := dialog.body.get_parent() as ScrollBody
	assert_true(scroll.custom_minimum_size.y < 800.0 * AbyssDialog.MAX_HEIGHT_SHARE)
	assert_true(scroll.custom_minimum_size.y > 400.0)
	assert_true(dialog.get_combined_minimum_size().y <= 800.0 * AbyssDialog.MAX_HEIGHT_SHARE + 1.0)
	tall.custom_minimum_size.y = 20.0
	dialog.fit(Vector2(390.0, 800.0))
	assert_true(scroll.custom_minimum_size.y <= 20.0, "a short body is not stretched")


func test_measures_its_chrome_again_once_laid_out() -> void:
	var dialog := mount(AbyssDialog.new("Settings")) as AbyssDialog
	var scroll := dialog._scroll as ScrollBody
	dialog.fit(Vector2(400.0, 800.0))
	var chrome := dialog.get_combined_minimum_size().y - scroll.custom_minimum_size.y
	dialog.set_title("A title of the settings of a game")
	dialog.resized.emit()
	var longer := dialog.get_combined_minimum_size().y - scroll.custom_minimum_size.y
	assert_almost_eq(scroll.max_height, maxf(800.0 * AbyssDialog.MAX_HEIGHT_SHARE - longer, 0.0), 0.5)
	assert_true(longer >= chrome)


func test_a_subclass_follows_the_language_through_refresh() -> void:
	var dialog := mount(LanguageAware.new()) as AbyssDialog
	assert_eq(dialog.title(), "Fermer")
	use_language("en")
	assert_eq(dialog.title(), "Close")


## A dialog whose title is a text of the game.
class LanguageAware:
	extends AbyssDialog

	func _init() -> void:
		super()
		refresh()

	func refresh() -> void:
		set_title(Texts.t(&"commonClose"))
