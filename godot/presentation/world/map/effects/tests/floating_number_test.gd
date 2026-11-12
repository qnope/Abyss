extends TestCase
## What a side lost in a round, floating up over it.

var _number: FloatingNumber


func before_each() -> void:
	_number = FloatingNumber.new()
	add_cleanup(_number.free)


func test_it_is_hidden_until_it_shows_a_loss() -> void:
	assert_false(_number.visible)
	_number.show_loss(Vector3.ZERO, 7, 0.0)
	assert_true(_number.visible)
	assert_eq(_number.text, "−7")


func test_it_rises_all_along_its_way() -> void:
	var from := Vector3(1.0, 0.5, 2.0)
	_number.show_loss(from, 3, 0.0)
	assert_eq(_number.position, from)
	_number.show_loss(from, 3, 1.0)
	assert_almost_eq(_number.position.y, from.y + FloatingNumber.RISE, 1e-6)
	assert_eq(_number.position.x, from.x)


func test_it_fades_over_its_second_half() -> void:
	_number.show_loss(Vector3.ZERO, 3, 0.4)
	assert_eq(_number.modulate.a, 1.0)
	_number.show_loss(Vector3.ZERO, 3, 0.75)
	assert_almost_eq(_number.modulate.a, 0.5, 1e-6)
	assert_almost_eq(_number.outline_modulate.a, 0.5, 1e-6)
	_number.show_loss(Vector3.ZERO, 3, 1.0)
	assert_eq(_number.modulate.a, 0.0)
