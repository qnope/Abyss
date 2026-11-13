extends TestCase
## What a part of the map drew last: the same asked again is not to draw.

var _drawn := Drawn.new()


func test_the_first_values_asked_are_to_draw() -> void:
	assert_false(_drawn.again([1, 6, 6]))


func test_the_same_values_again_are_drawn_already() -> void:
	_drawn.again([1, 6, 6, PackedInt32Array([0, 3]), Color.CYAN, null, Vector3(0.5, 0.0, 1.5)])
	for time in 2:
		assert_true(_drawn.again([1, 6, 6, PackedInt32Array([0, 3]), Color.CYAN, null, Vector3(0.5, 0.0, 1.5)]))


func test_any_other_value_is_to_draw_and_is_what_is_drawn_from_then_on() -> void:
	_drawn.again([1, 6, PackedInt32Array([0, 3]), null])
	for other: Array in [[2, 6, PackedInt32Array([0, 3]), null], [2, 8, PackedInt32Array([0, 3]), null],
			[2, 8, PackedInt32Array([0, 4]), null], [2, 8, PackedInt32Array([0, 4]), Color.CYAN], [2, 8]]:
		assert_false(_drawn.again(other), str(other))
		assert_true(_drawn.again(other), str(other))
	assert_false(_drawn.again([1, 6, PackedInt32Array([0, 3]), null]), "the first ones are forgotten")
