extends BuildingTestCase
## A line of an upgrade's list: green-white when met, red when not.


func _row(is_met: bool, amount := "3/5") -> RequirementRow:
	var row := RequirementRow.new(Control.new(), "Corail", amount, is_met)
	mount(row)
	return row


func test_a_met_line_is_in_the_text_colour() -> void:
	var row := _row(true)
	assert_true(row.met)
	assert_eq(row.label.text, "Corail")
	assert_eq(row.amount_label.text, "3/5")
	assert_eq(row.label.get_theme_color(&"font_color"), AbyssColors.ON_SURFACE)


func test_a_line_not_met_is_red() -> void:
	var row := _row(false)
	assert_eq(row.label.get_theme_color(&"font_color"), AbyssColors.ERROR)
	assert_eq(row.amount_label.get_theme_color(&"font_color"), AbyssColors.ERROR)


func test_without_an_amount_the_amount_is_hidden() -> void:
	assert_false(_row(true, "").amount_label.visible)
	assert_true(_row(true).amount_label.visible)


func test_a_padlock_line_is_tinted_by_whether_it_is_met() -> void:
	var met := RequirementRow.locked("Quartier Général", "Niv. 2", true)
	var unmet := RequirementRow.locked("Quartier Général", "Niv. 2", false)
	mount(met)
	mount(unmet)
	assert_true(met.met)
	assert_false(unmet.met)
	assert_eq((met.get_child(0) as UiIcon).self_modulate, AbyssColors.ON_SURFACE)
	assert_eq((unmet.get_child(0) as UiIcon).self_modulate, AbyssColors.ERROR)
