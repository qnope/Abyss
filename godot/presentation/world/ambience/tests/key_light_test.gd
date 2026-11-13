extends TestCase
## The light from the surface: one directional light, its shadows sized for
## a phone.


func test_falls_from_above_with_shadows_sized_for_a_phone() -> void:
	var light := KeyLight.new()
	var direction := -light.transform.basis.z
	assert_true(direction.y < -0.6, "from high above")
	assert_true(light.shadow_enabled)
	assert_eq(light.directional_shadow_mode, DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS)
	assert_false(light.directional_shadow_blend_splits)
	assert_eq(light.directional_shadow_max_distance, KeyLight.SHADOW_DISTANCE)
	assert_true(KeyLight.SHADOW_DISTANCE >= OrbitRig.MAX_DISTANCE + 10.0,
		"the island stays shadowed from the farthest view")
	light.free()


func test_turns_its_shadows_on_and_off() -> void:
	var light := KeyLight.new()
	light.set_shadows(false)
	assert_false(light.shadow_enabled)
	light.set_shadows(true)
	assert_true(light.shadow_enabled)
	light.free()


func test_wears_the_mood_of_a_place() -> void:
	var light := KeyLight.new()
	assert_eq(light.light_color, LightMoods.base().key_colour)
	assert_almost_eq(light.light_energy, LightMoods.base().key_energy, 1e-4)
	light.set_mood(LightMoods.core())
	assert_eq(light.light_color, LightMoods.core().key_colour)
	assert_almost_eq(light.light_energy, LightMoods.core().key_energy, 1e-4)
	assert_true(light.shadow_enabled, "its shadows are not the mood's")
	light.free()


func test_its_shadows_fit_a_phone_s_memory() -> void:
	var atlas: int = ProjectSettings.get_setting("rendering/lights_and_shadows/directional_shadow/size")
	assert_eq(atlas, 2048, "a 4096 atlas would cost 64 MB on the web of an iPhone")
