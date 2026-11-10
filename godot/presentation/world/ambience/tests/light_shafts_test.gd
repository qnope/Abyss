extends TestCase
## The rays of light from the surface: a few open cones along the light,
## drawn in one call, each wavering in its own time.


func test_draws_every_ray_in_one_call() -> void:
	var shafts := LightShafts.new(Vector3.DOWN)
	assert_eq(shafts.multimesh.instance_count, LightShafts.COUNT)
	assert_true(shafts.multimesh.use_custom_data, "each ray's phase")
	assert_eq(shafts.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	assert_eq((shafts.material_override as ShaderMaterial).shader, LightShafts.SHADER)
	assert_true(shafts.multimesh.mesh is QuadMesh, "a ribbon the shader turns")
	assert_eq(shafts.custom_aabb, LightShafts.BOUNDS)
	shafts.free()


func test_lays_the_rays_along_the_light_around_the_island() -> void:
	var direction := Vector3(0.2, -1.0, -0.6).normalized()
	var places := LightShafts.placements(direction)
	assert_eq(places.size(), LightShafts.COUNT)
	for place in places:
		assert_true(place.basis.y.normalized().is_equal_approx(-direction))
		assert_almost_eq(place.basis.y.length(), LightShafts.LENGTH, 1e-3)
		var crossing := place.origin - place.basis.y * 0.2
		assert_true(crossing.length() <= LightShafts.SPREAD)
	assert_ne(places[0].origin, places[1].origin)


func test_is_the_same_from_one_run_to_the_next() -> void:
	assert_eq(LightShafts.placements(Vector3.DOWN), LightShafts.placements(Vector3.DOWN))
