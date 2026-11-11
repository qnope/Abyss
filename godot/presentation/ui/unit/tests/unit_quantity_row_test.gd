extends UnitTestCase
## test/presentation/widgets/fight/unit_quantity_row_test.dart: how many of a
## type to take out of a stock.

var _values: Array[int] = []


func _show(stock := 5, value := 0) -> UnitQuantityRow:
	var row := UnitQuantityRow.new(Type.HARPOONIST, stock, value)
	mount(row)
	row.changed.connect(_values.append)
	return row


func test_shows_the_unit_its_stock_and_the_quantity() -> void:
	var row := _show(5, 2)
	assert_eq(row.name_label.text, "Harponneur")
	assert_eq(row.name_label.get_theme_color(&"font_color"), UnitColors.of(Type.HARPOONIST))
	assert_eq(row.stock_label.text, "Stock : 5")
	assert_eq(row.value_label.text, "2")
	assert_eq(row.slider.value, 2.0)
	assert_eq(row.slider.max_value, 5.0)
	assert_no_raw_keys()


func test_plus_and_minus_move_one_unit_and_tell_it() -> void:
	var row := _show()
	press(row.plus_button)
	press(row.plus_button)
	press(row.minus_button)
	assert_eq(_values, [1, 2, 1] as Array[int])
	assert_eq(row.value_label.text, "1")
	assert_eq(row.slider.value, 1.0)


func test_minus_is_dark_at_zero_and_plus_at_the_stock() -> void:
	var row := _show(2)
	assert_true(row.minus_button.disabled)
	assert_false(row.plus_button.disabled)
	row.set_value(2)
	assert_false(row.minus_button.disabled)
	assert_true(row.plus_button.disabled)


func test_the_slider_picks_a_quantity() -> void:
	var row := _show()
	row.slider.value = 4
	assert_eq(row.value, 4)
	assert_eq(_values, [4] as Array[int])


func test_never_takes_more_than_the_stock_nor_less_than_nothing() -> void:
	var row := _show(3)
	row.set_value(9)
	assert_eq(row.value, 3)
	row.set_value(-4)
	assert_eq(row.value, 0)
	row.set_value(-1, true)
	assert_eq(row.value, 0)


func test_tells_nothing_when_the_quantity_does_not_change() -> void:
	var row := _show(3, 1)
	row.set_value(1)
	row.set_value(9, true)
	row.set_value(2)
	assert_eq(_values, [3, 2] as Array[int])


func test_follows_the_language() -> void:
	var row := _show()
	use_language("en")
	assert_eq(row.stock_label.text, "Stock: 5")
	assert_eq(row.name_label.text, "Harpooner")
