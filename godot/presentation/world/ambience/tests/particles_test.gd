extends TestCase
## The specks in the water: marine snow drifting down around the base and
## bubbles rising from its buildings, both already under way when the scene
## opens, both cheap CPU particles that can be stopped.


func test_snow_drifts_down_around_the_island_from_the_start() -> void:
	var snow := MarineSnow.new()
	assert_eq(snow.amount, MarineSnow.AMOUNT)
	assert_true(snow.amount <= 300, "a modest count")
	assert_eq(snow.preprocess, snow.lifetime, "the water is full when the scene opens")
	assert_true(snow.gravity.y < 0.0)
	assert_eq(snow.emission_box_extents, MarineSnow.VOLUME)
	assert_eq(snow.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	assert_true(snow.mesh is QuadMesh)
	snow.free()


func test_bubbles_rise_from_around_each_source() -> void:
	var bubbles := RisingBubbles.new()
	assert_true(bubbles.amount <= 60, "a few at a time")
	assert_true(bubbles.gravity.y > 0.0)
	var sources := PackedVector3Array([Vector3(4.0, 0.12, 4.0), Vector3(-2.0, 0.12, 1.0)])
	bubbles.rise_from(sources)
	assert_eq(bubbles.emission_points.size(), 12)
	for point in bubbles.emission_points:
		var nearest := minf(_flat(point - sources[0]), _flat(point - sources[1]))
		assert_true(nearest <= RisingBubbles.SPREAD + 1e-4)
	bubbles.free()


func test_both_stop_and_hide() -> void:
	for particles: CPUParticles3D in [MarineSnow.new(), RisingBubbles.new()]:
		assert_true(particles.emitting)
		particles.call(&"set_running", false)
		assert_false(particles.emitting)
		assert_false(particles.visible)
		particles.call(&"set_running", true)
		assert_true(particles.emitting and particles.visible)
		particles.free()


func test_a_speck_is_an_unlit_soft_dot_facing_the_camera() -> void:
	var quad := ParticleDot.quad(0.1, 1.0, 0.5)
	assert_eq(quad.size, Vector2(0.1, 0.1))
	var material := quad.material as StandardMaterial3D
	assert_eq(material.shading_mode, BaseMaterial3D.SHADING_MODE_UNSHADED)
	assert_eq(material.billboard_mode, BaseMaterial3D.BILLBOARD_PARTICLES)
	assert_true(material.vertex_color_use_as_albedo, "the particle's colour")
	var dot := material.albedo_texture as GradientTexture2D
	assert_eq(dot.fill, GradientTexture2D.FILL_RADIAL)
	assert_eq(dot.gradient.colors[0].a, 1.0)
	assert_eq(dot.gradient.colors[1].a, 0.5)


static func _flat(offset: Vector3) -> float:
	return Vector2(offset.x, offset.z).length()
