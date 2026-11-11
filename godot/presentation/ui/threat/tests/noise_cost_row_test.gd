extends UiTestCase
## "+N bruit" under an action's cost (noise_cost_row_test.dart).


func test_tells_the_noise_of_the_action() -> void:
	var row := NoiseCostRow.new(3)
	mount(row)
	assert_eq(row.label.text, "Bruit")
	assert_eq(row.amount_label.text, "+3")
	assert_eq(row.amount_label.get_theme_color(&"font_color"), AbyssColors.WARNING)
	assert_no_raw_keys()


func test_follows_the_language() -> void:
	var row := NoiseCostRow.new(3)
	mount(row)
	use_language("en")
	assert_eq(row.label.text, Texts.t(&"raidNoise"))
	assert_ne(row.label.text, "Bruit")
