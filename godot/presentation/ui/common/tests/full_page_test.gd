extends UiTestCase
## The page over the whole screen: an app bar with a back button and a
## centred title, a body that scrolls.


func test_is_an_abyss_black_page_over_the_whole_screen() -> void:
	var page := mount(FullPage.new("Quests")) as FullPage
	assert_eq(page.theme_type_variation, &"PagePanel")
	assert_eq(page.placement, ModalPanel.Placement.FULL)
	assert_eq(page.title(), "Quests")


func test_shows_its_title_in_the_app_bar() -> void:
	var page := mount(FullPage.new("History")) as FullPage
	var title := find_text("History") as Label
	assert_eq(title.theme_type_variation, &"AppBarTitle")
	assert_eq(title.horizontal_alignment, HORIZONTAL_ALIGNMENT_CENTER)
	assert_eq((title.get_parent().get_parent() as Control).theme_type_variation, &"AppBarPanel")
	page.set_title("Journal")
	assert_not_null(find_text("Journal"))


func test_the_back_button_ends_the_page_with_no_result() -> void:
	var page := mount(FullPage.new("Page")) as FullPage
	var results := []
	page.closed.connect(func(result: Variant) -> void: results.append(result))
	assert_true(page.back_button.custom_minimum_size.y >= AbyssHudTheme.TOUCH_SIZE)
	var arrow := page.back_button.get_child(0) as UiIcon
	assert_eq(arrow.icon_path, "res://assets/icons/ui/arrow_back.svg")
	assert_eq(arrow.self_modulate, AbyssColors.BIOLUM_CYAN)
	press(page.back_button)
	assert_eq(results, [null])


func test_names_the_back_button_in_the_language_on() -> void:
	var page := mount(FullPage.new()) as FullPage
	assert_eq(page.back_button.tooltip_text, "Fermer")
	assert_eq(page.back_button.accessibility_name, "Fermer")
	use_language("es")
	assert_eq(page.back_button.tooltip_text, "Cerrar")


func test_its_body_scrolls_inside_the_room_that_is_left() -> void:
	var page := mount(FullPage.new()) as FullPage
	var tall := Control.new()
	tall.custom_minimum_size.y = 5000.0
	page.body.add_child(tall)
	assert_true(page.get_combined_minimum_size().y < 200.0, "it does not push the page")
	var scroll := page.body.get_parent().get_parent().get_parent() as ScrollBody
	assert_eq(scroll.size_flags_vertical, Control.SIZE_EXPAND_FILL)
	assert_eq((page.body.get_parent() as MarginContainer).get_theme_constant("margin_left"), 16)


func test_opens_on_a_layer_over_everything() -> void:
	var page := FullPage.new("Over")
	modals().open(page)
	assert_eq(current_modal(), page)
	press(page.back_button)
	assert_null(current_modal())
