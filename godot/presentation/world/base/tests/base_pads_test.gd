extends TestCase
## The island's pads: where each building stands, the empty ones marked
## discreetly on the deck, and the one under a tap.

const ISLAND := preload("res://assets/models/base_island.glb")

var _island: Node3D
var _pads: BasePads


func before_each() -> void:
	_island = ISLAND.instantiate() as Node3D
	_pads = BasePads.new(_island.get_node("Pads") as Node3D)


func after_each() -> void:
	_island.free()


func test_knows_every_pad_and_where_it_stands() -> void:
	assert_eq(_pads.names().size(), 11)
	assert_has(_pads.names(), &"Headquarters")
	assert_true(_pads.origin_of(&"Headquarters").is_equal_approx(Vector3(0.4, 0.12, 0.4)))


func test_marks_the_empty_pads_and_leaves_the_built_ones() -> void:
	_pads.mark([&"Headquarters", &"SolarPanel"] as Array[StringName])
	var empty := _pad(&"Barracks")
	assert_eq(empty.get_surface_override_material(0), _pads.marker.stone)
	assert_eq(empty.get_surface_override_material(1), _pads.marker.glow)
	assert_null(_pad(&"Headquarters").get_surface_override_material(0))
	assert_true(_pads.is_empty(&"Barracks"))
	assert_false(_pads.is_empty(&"SolarPanel"))
	_pads.mark([&"Barracks"] as Array[StringName])
	assert_null(empty.get_surface_override_material(0))
	assert_eq(_pad(&"Headquarters").get_surface_override_material(1), _pads.marker.glow)


func test_an_empty_pad_casts_no_shadow() -> void:
	_pads.mark([&"Headquarters"] as Array[StringName])
	assert_eq(_pad(&"Barracks").cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	assert_eq(_pad(&"Headquarters").cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)


func test_picks_the_pad_a_ray_meets_first() -> void:
	var headquarters := _pads.origin_of(&"Headquarters")
	var from_above := headquarters + Vector3(0.2, 30.0, 0.0)
	assert_eq(_pads.pick(from_above, Vector3.DOWN), &"Headquarters")
	var aside := Vector3(-4.0, 0.12, 4.0)
	assert_eq(_pads.pick(aside + Vector3.UP * 30.0, Vector3.DOWN), &"", "the deck between pads")
	var barracks := _pads.origin_of(&"Barracks")
	var low := barracks + Vector3(0.0, 0.4, 12.0)
	assert_eq(_pads.pick(low, Vector3.FORWARD), &"Barracks", "the nearest along the ray")


func _pad(name: StringName) -> MeshInstance3D:
	return _island.get_node("Pads/" + name) as MeshInstance3D


func test_tells_how_far_a_pad_reaches() -> void:
	for name: StringName in _pads.names():
		assert_true(_pads.radius_of(name) > 0.0, str(name))
