extends UiTestCase
## test/presentation/widgets/map/level_selector_test.dart: the chips of the
## depths of the map.

var _chosen: Array[int] = []


func _selector(current := 1, unlocked: Array[int] = [1]) -> LevelSelector:
	var selector := LevelSelector.new()
	selector.show_state(current, unlocked)
	selector.level_selected.connect(_chosen.append)
	mount(selector)
	return selector


func test_shows_the_three_levels_by_name() -> void:
	_selector()
	assert_not_null(find_text("Niv. 1 : Surface"))
	assert_not_null(find_text("Niv. 2 : Profondeurs"))
	assert_not_null(find_text("Niv. 3 : Noyau"))
	assert_no_raw_keys()


func test_names_the_levels_in_english_and_spanish() -> void:
	_selector()
	use_language("en")
	assert_not_null(find_text("Lv 2: Depths"))
	assert_not_null(find_text("Lv 3: Core"))
	use_language("es")
	assert_not_null(find_text("Niv 1: Superficie"))
	assert_not_null(find_text("Niv 3: Núcleo"))


func test_a_locked_level_has_a_padlock_and_cannot_be_touched() -> void:
	var selector := _selector()
	assert_null(selector.chips[1].icon)
	assert_not_null(selector.chips[2].icon)
	assert_true(selector.chips[2].disabled)
	assert_true(selector.chips[3].disabled)
	selector.chips[2].pressed.emit()
	selector.chips[2].disabled = true
	assert_eq(_chosen, [2] as Array[int], "a signal sent by hand still arrives; a touch cannot")


func test_touching_an_unlocked_level_tells_it() -> void:
	_selector(1, [1, 2])
	press("Niv. 2 : Profondeurs")
	assert_eq(_chosen, [2] as Array[int])


func test_every_level_unlocked_has_no_padlock() -> void:
	var selector := _selector(1, [1, 2, 3])
	for level: int in selector.chips:
		assert_null(selector.chips[level].icon)


func test_the_level_on_show_is_filled_and_the_others_outlined() -> void:
	var selector := _selector(2, [1, 2, 3])
	assert_eq(selector.chips[2].theme_type_variation, AbyssChipTheme.ACTIVE)
	assert_eq(selector.chips[1].theme_type_variation, AbyssChipTheme.CHIP)
	selector.show_state(1, [1, 2, 3])
	assert_eq(selector.chips[2].theme_type_variation, AbyssChipTheme.CHIP)
	assert_eq(selector.chips[1].theme_type_variation, AbyssChipTheme.ACTIVE)
