extends UiTestCase
## test/presentation/screens/menu/main_menu_layout_test.dart: the header near
## the top, the actions at the bottom, a column of a limited width.


func test_stacks_the_header_the_actions_and_the_footer_in_a_column() -> void:
	var layout := _layout()
	assert_eq(layout.column.get_child_count(), 6)
	assert_eq(texts(layout), PackedStringArray(["Header", "One", "Two", "Footer", "Gear"]))
	assert_eq(find_text("Header").get_parent().get_parent(), layout.column)
	assert_eq(find_text("One").get_parent().get_parent(), layout.column)
	assert_eq(find_text("Footer").get_parent(), layout.column)


func test_leaves_the_free_room_between_the_header_and_the_actions() -> void:
	var layout := _layout()
	layout.fit(Vector2(390.0, 844.0))
	var middle := layout.column.get_child(1) as Control
	assert_eq(middle.size_flags_vertical, Control.SIZE_EXPAND_FILL)
	assert_eq(middle.custom_minimum_size.y, float(MenuLayout.MIN_MIDDLE_GAP))


func test_keeps_the_corner_in_the_top_right() -> void:
	var layout := _layout()
	var corner := find_text("Gear")
	assert_eq(corner.get_parent(), layout)
	assert_eq(corner.size_flags_horizontal, Control.SIZE_SHRINK_END)
	assert_eq(corner.size_flags_vertical, Control.SIZE_SHRINK_BEGIN)


func test_limits_the_column_s_width_and_leaves_the_sides() -> void:
	var layout := _layout()
	layout.fit(Vector2(1280.0, 720.0))
	assert_eq(layout.column.custom_minimum_size.x, MenuLayout.MAX_WIDTH - 2.0 * MenuLayout.SIDE)
	layout.fit(Vector2(320.0, 640.0))
	assert_eq(layout.column.custom_minimum_size.x, 320.0 - 2.0 * MenuLayout.SIDE)


func test_leaves_a_tenth_of_the_height_above_the_header() -> void:
	var layout := _layout()
	layout.fit(Vector2(390.0, 844.0))
	assert_eq(_top_margin(layout), 84)
	layout.fit(Vector2(390.0, 500.0))
	assert_eq(_top_margin(layout), 50)
	layout.fit(Vector2(390.0, 100.0))
	assert_eq(_top_margin(layout), 12, "a short screen tightens the margin")


func test_tightens_every_gap_on_a_short_screen() -> void:
	var layout := _layout()
	layout.fit(Vector2(844.0, 390.0))
	assert_eq(_top_margin(layout), 12)
	assert_eq((layout.column.get_child(1) as Control).custom_minimum_size.y, 12.0)
	assert_eq((layout.column.get_child(2) as Control).get_theme_constant(&"separation"), 8)
	layout.fit(Vector2(390.0, 844.0))
	assert_eq((layout.column.get_child(2) as Control).get_theme_constant(&"separation"), 12)


func test_fits_itself_when_its_size_changes() -> void:
	var layout := _layout()
	layout.size = Vector2(844.0, 390.0)
	assert_eq(_top_margin(layout), 12)


func test_has_neither_footer_nor_corner_when_given_none() -> void:
	var layout := mount(MenuLayout.new(Label.new(), [])) as MenuLayout
	assert_false((layout.column.get_child(3) as Control).visible, "no gap for a footer")
	assert_eq(layout.get_child_count(), 1)


func _top_margin(layout: MenuLayout) -> int:
	return (layout.column.get_child(0) as Control).get_theme_constant(&"margin_top")


func _layout() -> MenuLayout:
	var actions: Array[Control] = [_label("One"), _label("Two")]
	return mount(MenuLayout.new(_label("Header"), actions, _label("Footer"), _label("Gear"))) as MenuLayout


func _label(text_written: String) -> Label:
	var label := Label.new()
	label.text = text_written
	return label
