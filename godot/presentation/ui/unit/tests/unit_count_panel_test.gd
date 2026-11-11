extends UnitTestCase
## test/presentation/widgets/unit/unit_count_panel_test.dart and
## unit_count_row (the army read, not touched).


func _show(units: Dictionary[UnitType.Value, int], empty := "") -> UnitCountPanel:
	var panel := UnitCountPanel.new("Défenseurs au Niveau 2", units, empty)
	mount(panel)
	return panel


func test_shows_the_title_the_total_and_a_row_per_type() -> void:
	var panel := _show({Type.HARPOONIST: 12, Type.GUARDIAN: 6})
	assert_not_null(find_text("Défenseurs au Niveau 2", panel))
	assert_eq(panel.total_label.text, "18")
	for shown: String in ["Harponneur", "12", "Gardien", "6"]:
		assert_not_null(find_text(shown, panel), shown)
	assert_eq(panel.total, 18)


func test_sorts_the_biggest_group_first() -> void:
	var panel := _show({Type.SCOUT: 2, Type.DOME_BREAKER: 9})
	assert_eq(panel.rows, [Type.DOME_BREAKER, Type.SCOUT] as Array[UnitType.Value])


func test_orders_equal_groups_by_unit_type() -> void:
	var panel := _show({Type.GUARDIAN: 3, Type.SCOUT: 3, Type.HARPOONIST: 3})
	assert_eq(panel.rows, [Type.SCOUT, Type.HARPOONIST, Type.GUARDIAN] as Array[UnitType.Value])


func test_leaves_out_the_types_without_unit() -> void:
	var panel := _show({Type.SCOUT: 0, Type.GUARDIAN: 4})
	assert_null(find_text("Éclaireur", panel))
	assert_not_null(find_text("Gardien", panel))


func test_fits_a_huge_group() -> void:
	var panel := _show({Type.ABYSS_ADMIRAL: 123456})
	assert_not_null(find_text("123456", panel))


func test_the_bars_follow_the_counts_of_the_biggest_group() -> void:
	var panel := _show({Type.SCOUT: 5, Type.GUARDIAN: 10})
	var bars := find_type("ProgressBar", panel)
	assert_eq(bars.size(), 2)
	assert_eq((bars[0] as ProgressBar).value / (bars[0] as ProgressBar).max_value, 1.0)
	assert_eq((bars[1] as ProgressBar).value / (bars[1] as ProgressBar).max_value, 0.5)


func test_says_so_when_nobody_is_there() -> void:
	var panel := _show({}, "Aucune unité.")
	assert_true(panel.alert)
	assert_eq(panel.total_label.text, "0")
	assert_not_null(find_text("Aucune unité.", panel))
	assert_eq(panel.total_label.get_theme_color(&"font_color"), AbyssColors.CORAL_PINK)


func test_is_not_an_alert_without_a_message_or_with_units() -> void:
	assert_false(_show({}).alert)
	var panel := _show({Type.SCOUT: 1}, "Aucune unité.")
	assert_false(panel.alert)
	assert_null(find_text("Aucune unité.", panel))
	assert_eq(panel.total_label.get_theme_color(&"font_color"), AbyssColors.ENERGY_YELLOW)


func test_draws_a_picture_of_each_unit() -> void:
	var panel := _show({Type.HARPOONIST: 1, Type.GUARDIAN: 1})
	assert_eq(portraits_in(panel).size(), 2)


func test_a_row_tells_how_many_in_the_plural_of_the_language() -> void:
	var row := UnitCountRow.new(Type.SCOUT, 3)
	mount(row)
	assert_eq(row.label.text, "3 éclaireurs")
	use_language("en")
	assert_eq(row.label.text, "3 scouts")
	assert_no_raw_keys()
