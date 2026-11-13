extends TestCase
## The light of each place: the base's as it was reviewed, and one for each
## level of the map, bright teal, twilight blue and dark red, none too dark
## for the models' colours to be told apart.


func test_the_base_keeps_the_light_it_was_reviewed_in() -> void:
	var mood := LightMoods.base()
	assert_eq(mood.key_colour, Color("fff3e2"))
	assert_eq(mood.key_energy, 2.0)
	assert_eq(mood.ambient_energy, 2.4)
	assert_eq(mood.fog_colour, Color("082a3c"))
	assert_eq(mood.fog_density, 0.006)
	assert_eq(mood.sky_surface, Color(0.16, 0.42, 0.52))
	assert_eq(mood.sky_horizon, Color(0.05, 0.19, 0.28))
	assert_eq(mood.sky_abyss, Color(0.008, 0.035, 0.07))


func test_each_level_has_its_own_light() -> void:
	var moods: Array[LightMood] = [LightMoods.surface(), LightMoods.depths(), LightMoods.core()]
	for index in 3:
		assert_eq(LightMoods.of_level(index + 1).key_colour, moods[index].key_colour)
		assert_ne(moods[index].key_colour, LightMoods.base().key_colour)
	assert_eq(LightMoods.of_level(0).key_colour, LightMoods.surface().key_colour, "none is the first")
	assert_eq(LightMoods.of_level(7).key_colour, LightMoods.core().key_colour, "the deepest serves below")


func test_the_surface_is_teal_the_depths_blue_and_the_core_red() -> void:
	var surface := LightMoods.surface().sky_surface
	assert_true(surface.g > surface.r and surface.g >= surface.b, "teal")
	var depths := LightMoods.depths().sky_surface
	assert_true(depths.b > depths.g and depths.b > depths.r * 2.0, "blue")
	var core := LightMoods.core().sky_surface
	assert_true(core.r > core.g * 2.0 and core.r > core.b * 2.0, "red")
	var fog := LightMoods.core().fog_colour
	assert_true(fog.r > fog.b * 2.0, "the fog glows red too")


func test_no_light_leaves_the_models_in_the_dark() -> void:
	for mood: LightMood in [LightMoods.base(), LightMoods.surface(), LightMoods.depths(), LightMoods.core()]:
		assert_true(mood.key_energy >= 2.0, "a key light as bright as the base's")
		assert_true(mood.ambient_energy >= 2.3)
		assert_true(mood.fog_density <= 0.008, "fog that leaves the slab in view")
		assert_true(mood.key_colour.get_luminance() >= 0.6, "a light that does not tint the models too far")
