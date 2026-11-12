extends TestCase
## The school of small fish drifting round the islet.

var _school: FishSchool


func before_each() -> void:
	_school = FishSchool.new()


func after_each() -> void:
	_school.free()


func test_is_one_cheap_draw_of_small_fish() -> void:
	assert_eq(_school.multimesh.instance_count, FishSchool.COUNT)
	assert_eq(_school.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	var body := _school.multimesh.mesh as SphereMesh
	assert_true(body.radial_segments * body.rings <= 24, "a few dozen triangles")
	var material := body.material as StandardMaterial3D
	assert_eq(material.albedo_color, WorldPalette.FISH)


func test_the_fish_keep_to_a_cloud_round_the_circle() -> void:
	for index in FishSchool.COUNT:
		var flat := Vector2(_school.placement(index, 0.0).origin.x, _school.placement(index, 0.0).origin.z)
		assert_true(absf(flat.length() - FishSchool.RADIUS) <= FishSchool.CLOUD.length() + FishSchool.WAVER)
		var height := _school.placement(index, 0.0).origin.y
		assert_true(absf(height - FishSchool.HEIGHT) <= FishSchool.CLOUD.z + 1e-4)


func test_the_school_swims_a_lap_and_is_back() -> void:
	var start := _school.placement(3, 0.0).origin
	var quarter := _school.placement(3, FishSchool.LAP / 4.0).origin
	assert_true(start.distance_to(quarter) > FishSchool.RADIUS)
	var lap := _school.placement(3, FishSchool.LAP).origin
	assert_true(start.distance_to(lap) < FishSchool.WAVER * 2.0 + 0.5)


func test_every_fish_points_the_way_the_school_goes() -> void:
	for t: float in [0.0, 17.0, 40.0]:
		var place := _school.placement(0, t)
		var nose := place.basis.orthonormalized() * Vector3.FORWARD
		var angle := TAU * t / FishSchool.LAP
		assert_true(nose.dot(Vector3(-sin(angle), 0.0, cos(angle))) > 0.99)
		assert_almost_eq(place.basis.get_scale().z, FishSchool.BODY.z, 1e-4)


func test_advance_lets_the_clock_run_and_wraps_it() -> void:
	_school.advance(5.0)
	assert_eq(_school._time, 5.0)
	_school._process(0.5)
	assert_eq(_school._time, 5.5)
	_school.advance(FishSchool.LAP * 10.0)
	assert_almost_eq(_school._time, 5.5, 1e-3)
