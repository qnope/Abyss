extends MapTestCase
## The guide's ring on the floor: where it lies, its name, its pulse.

var _ring: GuideRing


func before_each() -> void:
	_ring = GuideRing.new()
	mounted(_ring)



func test_is_hidden_until_it_points_somewhere() -> void:
	assert_false(_ring.visible)
	assert_false(_ring.is_pulsing())


func test_rings_the_floor_around_a_point() -> void:
	_ring.point_at(Vector3(2, 0, 3), 1.5)
	assert_true(_ring.visible)
	assert_eq(_ring.radius, 1.5)
	assert_eq(_ring.position.x, 2.0)
	assert_eq(_ring.position.z, 3.0)
	assert_true(_ring.position.y > 0.0)
	assert_false(_ring.caption.visible)
	assert_true(_ring.is_pulsing())


func test_writes_the_name_over_the_ring() -> void:
	_ring.point_at(Vector3.ZERO, 1.0, "QG")
	assert_true(_ring.caption.visible)
	assert_eq(_ring.caption.text, "QG")


func test_a_radius_smaller_than_the_tube_leaves_no_hole() -> void:
	_ring.point_at(Vector3.ZERO, 0.0)
	assert_eq((_ring.ring.mesh as TorusMesh).inner_radius, 0.0)


func test_clear_hides_and_stops_the_pulse() -> void:
	_ring.point_at(Vector3.ZERO, 1.0)
	_ring.clear()
	assert_false(_ring.visible)
	assert_false(_ring.is_pulsing())


func test_holds_still_with_reduced_motion() -> void:
	_ring.reduced_motion = true
	_ring.point_at(Vector3.ZERO, 1.0)
	assert_false(_ring.is_pulsing())
	assert_eq(_ring.pulse, 1.0)


func test_the_pulse_dims_and_swells_the_ring() -> void:
	_ring._show(0.0)
	var dim := _alpha()
	_ring._show(1.0)
	assert_true(_alpha() > dim)
	assert_true(_ring.ring.scale.x > 1.0)


func _alpha() -> float:
	return ((_ring.ring.mesh as TorusMesh).material as StandardMaterial3D).albedo_color.a
