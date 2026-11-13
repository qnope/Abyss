extends MapTestCase
## What lives round and over the slab follows the level shown, and the map
## stops it, with the particles setting, through the scene.

var _scene: MapScene


func before_each() -> void:
	_scene = MapScene.new()
	mounted(_scene)


func test_dresses_the_level_with_its_scenery_creature_and_specks() -> void:
	_scene.show_level(level_of(6, 6, [], false, 3))
	var around := _scene.surroundings
	assert_not_null(around.ambient.creature)
	assert_true(around.backdrop.get_child_count() > 0)
	assert_eq(around.specks.color, SpeckLooks.core().colour)
	assert_true(around.specks.emitting)


func test_stops_the_specks_with_the_quality_panel() -> void:
	_scene.show_level(level_of())
	_scene.set_particles(false)
	assert_false(_scene.surroundings.specks.emitting)
	assert_false(_scene.surroundings.specks.visible)
	_scene.set_particles(true)
	assert_true(_scene.surroundings.specks.emitting)


func test_the_specks_stop_with_the_hidden_scene() -> void:
	_scene.show_level(level_of())
	_scene.visible = false
	_scene.process_mode = Node.PROCESS_MODE_DISABLED
	assert_false(_scene.surroundings.specks.can_process())
	assert_false(_scene.surroundings.specks.is_visible_in_tree())
