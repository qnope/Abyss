extends TestCase
## A ring or a disc of light on the floor.

var _ring := FloorMark.new()
var _disc := FloorMark.new(false)


func after_each() -> void:
	_ring.free()
	_disc.free()


func test_a_ring_is_a_thin_torus_and_a_disc_a_flat_cylinder() -> void:
	assert_true(_ring.mesh is TorusMesh)
	assert_true(_disc.mesh is CylinderMesh)
	assert_eq(_ring.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	assert_almost_eq(_ring.position.y, FloorMark.HEIGHT, 1e-6)


func test_it_is_hidden_until_shown() -> void:
	assert_false(_ring.visible)


func test_it_shows_across_a_radius_in_a_colour_at_an_opacity() -> void:
	_disc.show_mark(2.0, Color.RED, 0.5)
	assert_true(_disc.visible)
	assert_eq(_disc.scale, Vector3(2.0, 1.0, 2.0))
	var colour := (_disc.material_override as StandardMaterial3D).albedo_color
	assert_eq(colour, Color(Color.RED, 0.5))


func test_it_does_not_show_without_opacity_or_radius() -> void:
	_disc.show_mark(2.0, Color.RED, 0.0)
	assert_false(_disc.visible)
	_disc.show_mark(0.0, Color.RED, 1.0)
	assert_false(_disc.visible)


func test_an_opacity_over_one_is_one() -> void:
	_ring.show_mark(1.0, Color.RED, 3.0)
	assert_eq((_ring.material_override as StandardMaterial3D).albedo_color.a, 1.0)
