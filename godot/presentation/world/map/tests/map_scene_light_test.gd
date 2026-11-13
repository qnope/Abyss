extends MapTestCase
## The light of the map: each level is lit as its own place, and tells the
## world, which owns the water, which level it shows.

var _scene: MapScene
var _shown: Array[int] = []


func before_each() -> void:
	_scene = MapScene.new()
	_scene.level_shown.connect(func(level: int) -> void: _shown.append(level))
	mounted(_scene)


func test_lights_each_level_with_its_own_key_light() -> void:
	for level: int in [1, 2, 3]:
		_scene.show_level(level_of(6, 6, [], false, level))
		var mood := LightMoods.of_level(level)
		assert_eq(_scene.key_light.light_color, mood.key_colour, "level %d" % level)
		assert_almost_eq(_scene.key_light.light_energy, mood.key_energy, 1e-4)


func test_tells_which_level_it_shows_each_time_it_is_drawn() -> void:
	_scene.show_level(level_of(6, 6, [], false, 2))
	_scene.show_level(level_of(6, 6, [], false, 2))
	_scene.show_level(level_of(6, 6, [], false, 3))
	assert_eq(_shown, [2, 2, 3] as Array[int])
