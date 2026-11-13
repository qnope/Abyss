extends TestCase
## The light of the world: the water takes the mood of the view on show, the
## base's, or the level's of the map.

var _world: WorldHost


func before_each() -> void:
	_world = WorldHost.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(_world)


func after_each() -> void:
	_world.free()


func _fog() -> Color:
	return _world.base.water.environment.fog_light_color


func _level(level: int) -> MapLevelState:
	return MapLevelState.new(level, MapSamples.plain_map(6, 6), "me")


func test_the_base_and_the_parade_ground_are_lit_as_the_base() -> void:
	assert_eq(_fog(), LightMoods.base().fog_colour)
	_world.show_view(WorldHost.View.PARADE)
	assert_eq(_fog(), LightMoods.base().fog_colour)


func test_the_map_is_lit_as_the_level_it_shows() -> void:
	_world.show_view(WorldHost.View.MAP)
	_world.map.show_level(_level(3))
	assert_eq(_fog(), LightMoods.core().fog_colour)
	_world.map.show_level(_level(2))
	assert_eq(_fog(), LightMoods.depths().fog_colour)
	_world.show_view(WorldHost.View.BASE)
	assert_eq(_fog(), LightMoods.base().fog_colour, "back on the base")
	_world.show_view(WorldHost.View.MAP)
	assert_eq(_fog(), LightMoods.depths().fog_colour, "the level it showed")


func test_a_level_drawn_behind_another_view_leaves_the_water_alone() -> void:
	_world.map.show_level(_level(3))
	assert_eq(_fog(), LightMoods.base().fog_colour)
