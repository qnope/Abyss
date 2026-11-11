extends UiTestCase
## A row of chips, one lit, that tells which was touched.

var _chosen: Array = []


func _row(selected: Variant = 1) -> ChipRow:
	var items: Array[SegmentItem] = [
		SegmentItem.new(1, "Tous", "Tous"), SegmentItem.new(2, "Combats", "Combats"),
		SegmentItem.new(3, "Autres", "Autres")]
	var row := ChipRow.new(items, selected)
	row.chosen.connect(_chosen.append)
	return mount(row) as ChipRow


func before_each() -> void:
	_chosen = []


func test_one_chip_per_item_in_order() -> void:
	var row := _row()
	assert_eq(texts(row), PackedStringArray(["Tous", "Combats", "Autres"]))
	assert_eq(row.button(2).accessibility_name, "Combats")


func test_the_lit_chip_is_filled_and_the_others_outlined() -> void:
	var row := _row(2)
	assert_eq(row.selected(), 2)
	assert_eq(row.button(2).theme_type_variation, &"")
	assert_eq(row.button(1).theme_type_variation, &"OutlinedButton")
	assert_eq(row.button(3).theme_type_variation, &"OutlinedButton")


func test_a_touch_lights_the_chip_and_tells_it() -> void:
	var row := _row()
	press("Autres")
	assert_eq(_chosen, [3])
	assert_eq(row.selected(), 3)
	assert_eq(row.button(3).theme_type_variation, &"")
	assert_eq(row.button(1).theme_type_variation, &"OutlinedButton")


func test_a_touch_on_the_lit_chip_tells_nothing() -> void:
	_row()
	press("Tous")
	assert_eq(_chosen, [] as Array)


func test_select_lights_a_chip_without_telling_it() -> void:
	var row := _row()
	row.select(2)
	assert_eq(row.selected(), 2)
	assert_eq(_chosen, [] as Array)
	assert_eq(row.button(2).theme_type_variation, &"")


func test_scrolls_sideways_only() -> void:
	var row := _row()
	assert_eq(row.vertical_scroll_mode, ScrollContainer.SCROLL_MODE_DISABLED)
