extends TestCase
## The deep sea's environment: a gradient of water for sky and ambient
## light, fog thickening with distance and depth, glow on the lights, and a
## tone mapping that keeps their colours.

var _world: UnderwaterEnvironment
var _environment: Environment


func before_each() -> void:
	_world = UnderwaterEnvironment.new()
	_environment = _world.environment


func after_each() -> void:
	_world.free()


func test_surrounds_the_base_with_a_gradient_of_water() -> void:
	assert_eq(_environment.background_mode, Environment.BG_SKY)
	var sky := _environment.sky.sky_material as ShaderMaterial
	assert_eq(sky.shader, UnderwaterEnvironment.SKY_SHADER)
	assert_eq(_environment.sky.radiance_size, Sky.RADIANCE_SIZE_32)
	assert_eq(_environment.ambient_light_source, Environment.AMBIENT_SOURCE_SKY)


func test_thickens_its_fog_with_distance_and_depth() -> void:
	assert_true(_environment.fog_enabled)
	assert_eq(_environment.fog_mode, Environment.FOG_MODE_EXPONENTIAL)
	assert_true(_environment.fog_density > 0.0)
	assert_true(_environment.fog_height < 0.0, "under the deck")
	assert_true(_environment.fog_height_density > 0.0)
	assert_eq(_environment.fog_sky_affect, 0.0, "the sky is its own fog")


func test_glows_the_lights_only() -> void:
	assert_true(_environment.glow_enabled)
	assert_true(_environment.glow_hdr_threshold >= 0.8)
	assert_eq(_environment.glow_bloom, 0.0)


func test_tone_maps_without_washing_out_the_lights() -> void:
	assert_eq(_environment.tonemap_mode, UnderwaterEnvironment.TONEMAPPER)
	assert_true(_environment.adjustment_enabled)
	assert_true(_environment.adjustment_saturation > 1.0)


func test_is_lit_as_the_base_until_told_otherwise() -> void:
	var base := LightMoods.base()
	assert_eq(_environment.fog_light_color, base.fog_colour)
	assert_almost_eq(_environment.fog_density, base.fog_density, 1e-6)
	assert_almost_eq(_environment.ambient_light_energy, base.ambient_energy, 1e-4)
	var sky := _environment.sky.sky_material as ShaderMaterial
	assert_eq(sky.get_shader_parameter(&"surface_colour"), base.sky_surface)


func test_wears_the_mood_of_a_level() -> void:
	var core := LightMoods.core()
	_world.set_mood(core)
	assert_eq(_environment.fog_light_color, core.fog_colour)
	assert_almost_eq(_environment.fog_density, core.fog_density, 1e-6)
	assert_almost_eq(_environment.ambient_light_energy, core.ambient_energy, 1e-4)
	var sky := _environment.sky.sky_material as ShaderMaterial
	assert_eq(sky.get_shader_parameter(&"surface_colour"), core.sky_surface)
	assert_eq(sky.get_shader_parameter(&"horizon_colour"), core.sky_horizon)
	assert_eq(sky.get_shader_parameter(&"abyss_colour"), core.sky_abyss)
	var depths := UnderwaterEnvironment.new(LightMoods.depths())
	assert_eq(depths.environment.fog_light_color, LightMoods.depths().fog_colour, "or from the start")
	depths.free()


func test_turns_the_glow_on_and_off() -> void:
	_world.set_glow(false)
	assert_false(_environment.glow_enabled)
	_world.set_glow(true)
	assert_true(_environment.glow_enabled)
