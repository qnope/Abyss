extends UiTestCase
## test/presentation/widgets/army/army_place_bar_test.dart.

const Scout := UnitType.Value.SCOUT
const KERNEL := KernelGarrison.STOCK_KEY
const ALL := ArmyPlaces.ALL

var _chosen: Array[int] = []


func _show(selected := ALL) -> ArmyPlaceBar:
	var places := ArmyPlaces.new({1: {Scout: 96}, 2: {Scout: 31}, 3: {Scout: 0}, KERNEL: {Scout: 12}})
	var bar := ArmyPlaceBar.new(places, selected)
	mount(bar)
	bar.chosen.connect(_chosen.append)
	return bar


func test_lists_all_then_each_place_holding_units_with_its_count() -> void:
	var bar := _show()
	for shown: String in ["Toutes", "139", "Niv. 1", "96", "Niv. 2", "31", "Noyau", "12"]:
		assert_not_null(find_text(shown, bar), shown)
	assert_null(find_text("Niv. 3", bar))
	assert_no_raw_keys()


func test_lights_the_place_it_is_given() -> void:
	var bar := _show(2)
	assert_eq(bar.bar.selected(), 2)
	bar.select(KERNEL)
	assert_eq(bar.bar.selected(), KERNEL)
	assert_eq(bar.selected, KERNEL)


func test_touching_a_place_tells_it_all_included() -> void:
	_show(2)
	press("Noyau")
	press("Toutes")
	assert_eq(_chosen, [KERNEL, ALL] as Array[int])


func test_each_place_is_named_for_a_screen_reader() -> void:
	var bar := _show(2)
	assert_eq(bar.bar.button(2).accessibility_name, "Niveau 2, 31 unités")
	assert_eq(bar.bar.button(ALL).accessibility_name, "Toutes, 139 unités")
	assert_eq(bar.bar.button(KERNEL).accessibility_name, "Noyau, 12 unités")


func test_shows_other_places_when_it_is_given_them() -> void:
	var bar := _show()
	bar.show_places(ArmyPlaces.new({1: {Scout: 5}, 2: {Scout: 4}}), 2)
	assert_null(find_text("Noyau", bar))
	assert_not_null(find_text("9", bar))
	assert_eq(bar.bar.selected(), 2)
	assert_eq(find_type("SegmentedBar", bar).size(), 1, "the tray is replaced")


func test_names_the_places_in_english_and_spanish() -> void:
	var bar := _show()
	use_language("en")
	for shown: String in ["All", "Lv. 1", "Lv. 2", "Core"]:
		assert_not_null(find_text(shown, bar), shown)
	use_language("es")
	assert_not_null(find_text("Todas", bar))
	assert_not_null(find_text("Núcleo", bar))
	assert_no_raw_keys()


func test_keeps_the_room_it_takes_at_the_bottom_of_a_view() -> void:
	assert_eq(ArmyPlaceBar.ROOM, AbyssSegmentedTheme.HEIGHT + 16.0)
	var bar := _show()
	assert_eq(bar.mouse_filter, Control.MOUSE_FILTER_IGNORE)
