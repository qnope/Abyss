extends UiTestCase
## The tray of segments sharing its width, one of them lit.

var _chosen: Array = []


func test_is_a_themed_tray_as_high_as_the_theme_says() -> void:
	var bar := _bar(&"base")
	assert_eq(bar.theme_type_variation, &"SegmentedTray")
	assert_eq(bar.custom_minimum_size.y, AbyssSegmentedTheme.HEIGHT)


func test_shows_a_segment_per_item_with_its_name_and_detail() -> void:
	var bar := _bar(&"base")
	assert_eq(bar.name_label(&"base").text, "Base")
	assert_eq(bar.name_label(&"base").theme_type_variation, &"SegmentName")
	assert_eq(bar.detail_label(&"base").text, "3")
	assert_eq(bar.detail_label(&"base").theme_type_variation, &"SegmentDetail")
	assert_null(bar.detail_label(&"map"), "no detail, no line")
	assert_eq(texts(bar), PackedStringArray(["Base", "3", "Carte"]))


func test_every_segment_is_a_toggle_of_one_group_sharing_the_width() -> void:
	var bar := _bar(&"base")
	var group := bar.button(&"base").button_group
	assert_not_null(group)
	for value: StringName in [&"base", &"map"]:
		var button := bar.button(value)
		assert_true(button.toggle_mode)
		assert_eq(button.button_group, group)
		assert_eq(button.theme_type_variation, &"Segment")
		assert_eq(button.size_flags_horizontal, Control.SIZE_EXPAND_FILL)
		assert_eq(bar.name_label(value).text_overrun_behavior, TextServer.OVERRUN_TRIM_ELLIPSIS)


func test_screen_readers_get_the_spoken_label_of_each_segment() -> void:
	var bar := _bar(&"base")
	assert_eq(bar.button(&"base").accessibility_name, "Onglet base, 3 bâtiments")
	assert_eq(bar.button(&"map").accessibility_name, "Onglet carte")


func test_lights_the_selected_segment() -> void:
	var bar := _bar(&"map")
	assert_true(bar.button(&"map").button_pressed)
	assert_false(bar.button(&"base").button_pressed)
	assert_eq(bar.selected(), &"map")
	assert_eq(bar.name_label(&"map").get_theme_color(&"font_color"), AbyssSegmentedTheme.ON_SELECTED)
	assert_eq(bar.name_label(&"base").get_theme_color(&"font_color"), AbyssSegmentedTheme.LABEL_COLOR)
	assert_eq(bar.detail_label(&"base").get_theme_color(&"font_color"), AbyssSegmentedTheme.DETAIL_COLOR)


func test_a_touch_tells_the_value_and_lights_the_segment() -> void:
	var bar := _bar(&"base")
	press(bar.button(&"map"))
	assert_eq(_chosen, [&"map"])
	assert_eq(bar.selected(), &"map")
	assert_eq(bar.name_label(&"map").get_theme_color(&"font_color"), AbyssSegmentedTheme.ON_SELECTED)
	assert_eq(bar.name_label(&"base").get_theme_color(&"font_color"), AbyssSegmentedTheme.LABEL_COLOR)
	assert_eq(bar.detail_label(&"base").get_theme_color(&"font_color"), AbyssSegmentedTheme.DETAIL_COLOR)


func test_a_touch_on_the_lit_segment_tells_it_too_and_keeps_it_lit() -> void:
	var bar := _bar(&"base")
	press(bar.button(&"base"))
	assert_eq(_chosen, [&"base"])
	assert_eq(bar.selected(), &"base")


func test_selects_from_outside_without_telling() -> void:
	var bar := _bar(&"base")
	bar.select(&"map")
	assert_eq(bar.selected(), &"map")
	assert_eq(_chosen, [])
	assert_eq(bar.detail_label(&"base").get_theme_color(&"font_color"), AbyssSegmentedTheme.DETAIL_COLOR)
	bar.select(&"unknown")
	assert_eq(bar.selected(), &"map", "a value no segment has changes nothing")


func test_no_segment_is_lit_when_the_selection_is_unknown() -> void:
	assert_null(_bar(&"nothing").selected())


func test_texts_pressed_by_name_reach_the_touch_area_through_the_bar() -> void:
	var bar := _bar(&"base")
	assert_eq(find_text("Carte", bar), bar.name_label(&"map"))


func _bar(selected: StringName) -> SegmentedBar:
	var items: Array[SegmentItem] = [
		SegmentItem.new(&"base", "Base", "Onglet base, 3 bâtiments", "3"),
		SegmentItem.new(&"map", "Carte", "Onglet carte"),
	]
	var bar := SegmentedBar.new(items, selected)
	bar.chosen.connect(func(value: Variant) -> void: _chosen.append(value))
	mount(bar)
	return bar
