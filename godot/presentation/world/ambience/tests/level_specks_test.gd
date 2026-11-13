extends TestCase
## The specks of the map's levels: marine snow on the surface, bubbles in the
## depths, ash in the core, drifting over the slab, cheap, and stopped with the
## particles setting or when the map is out of sight.

var _specks: LevelSpecks


func before_each() -> void:
	_specks = LevelSpecks.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(_specks)


func after_each() -> void:
	_specks.free()


func test_drifts_nothing_until_a_level_is_shown() -> void:
	assert_false(_specks.emitting)


func test_each_level_has_its_own_specks() -> void:
	var seen: Array[Color] = []
	for level: int in [1, 2, 3]:
		_specks.show_level(level, 20, 20)
		var look := SpeckLooks.of_level(level)
		assert_eq(_specks.amount, look.amount)
		assert_eq(_specks.color, look.colour)
		assert_eq(_specks.preprocess, look.lifetime, "the water is full when the level opens")
		assert_almost_eq(_specks.gravity.y, look.lift, 1e-6)
		assert_true(_specks.emitting)
		seen.append(_specks.color)
	assert_eq(seen.size(), 3)
	assert_ne(seen[0], seen[1])
	assert_ne(seen[1], seen[2])


func test_snow_falls_bubbles_and_ash_rise() -> void:
	assert_true(SpeckLooks.surface().lift < 0.0)
	assert_true(SpeckLooks.depths().lift > 0.0)
	assert_true(SpeckLooks.core().lift > 0.0)
	assert_true(SpeckLooks.core().colour.r > SpeckLooks.core().colour.b * 2.0, "warm")
	assert_eq(SpeckLooks.of_level(9).colour, SpeckLooks.core().colour, "the deepest serves below")


func test_drifts_over_the_whole_slab_and_a_little_beyond() -> void:
	_specks.show_level(1, 26, 18)
	assert_eq(_specks.emission_box_extents.x, 13.0 + LevelSpecks.MARGIN)
	assert_eq(_specks.emission_box_extents.z, 9.0 + LevelSpecks.MARGIN)
	assert_almost_eq(_specks.position.y - _specks.emission_box_extents.y, 0.2, 1e-4, "over the floor")


func test_is_a_few_unlit_dots_in_one_draw() -> void:
	for level: int in [1, 2, 3]:
		assert_true(SpeckLooks.of_level(level).amount <= 160, "a modest count")
	_specks.show_level(2, 20, 20)
	assert_eq(_specks.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	var material := (_specks.mesh as QuadMesh).material as StandardMaterial3D
	assert_eq(material.shading_mode, BaseMaterial3D.SHADING_MODE_UNSHADED)


func test_the_same_level_again_does_not_restart_it() -> void:
	_specks.show_level(1, 20, 20)
	var mesh := _specks.mesh
	_specks.show_level(1, 20, 20)
	assert_eq(_specks.mesh, mesh)
	_specks.show_level(1, 22, 20)
	assert_ne(_specks.mesh, mesh, "a map of another size is another box")


func test_stops_and_hides_with_the_particles_setting() -> void:
	_specks.show_level(3, 20, 20)
	_specks.set_running(false)
	assert_false(_specks.emitting)
	assert_false(_specks.visible)
	_specks.show_level(2, 20, 20)
	assert_false(_specks.emitting, "a level drawn while stopped stays stopped")
	_specks.set_running(true)
	assert_true(_specks.emitting and _specks.visible)
