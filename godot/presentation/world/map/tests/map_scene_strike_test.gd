extends MapTestCase
## An army striking what stands on a cell of the level shown.

var _scene: MapScene
var _ended := 0


func before_each() -> void:
	_scene = mounted(MapScene.new()) as MapScene
	_ended = 0


func _done() -> void:
	_ended += 1


func test_without_a_level_the_strike_is_over_at_once() -> void:
	_scene.strike(StrikeSamples.strike(), _done)
	assert_eq(_ended, 1)
	assert_false(_scene.effects.is_playing())
	_scene.strike(StrikeSamples.strike())
	assert_false(_scene.effects.is_playing())


func test_a_strike_plays_from_the_scouts_origin_over_what_stands_there() -> void:
	var state := _level()
	_scene.show_level(state)
	_scene.strike(StrikeSamples.strike(Vector2i(3, 3)), _done)
	var effect := _scene.effects.current as StrikeEffect
	assert_not_null(effect)
	assert_eq(effect.get_parent(), _scene.effects)
	assert_eq(effect.geometry.target, Vector2i(3, 3))
	assert_eq(effect.geometry.width, 8)
	assert_eq(_ended, 0)
	_scene.effects.current.finish()
	assert_eq(_ended, 1)


func test_a_strike_on_a_lair_has_its_monster() -> void:
	_scene.show_level(_level())
	_scene.strike(StrikeSamples.strike(Vector2i(3, 3), true, StrikeSamples.lair()))
	assert_not_null((_scene.effects.current as StrikeEffect).monster)


func test_the_camera_is_shaken_by_the_blows() -> void:
	_scene.show_level(_level())
	_scene.strike(StrikeSamples.strike(Vector2i(3, 3)))
	var effect := _scene.effects.current as StrikeEffect
	effect.advance(effect.timeline.pace().hit_at(0) + 0.03)
	_scene.effects._process(0.0)
	assert_true(_scene.camera.jolt != 0.0)


func test_a_siege_plays_over_the_place_it_besieges() -> void:
	_scene.show_level(_level())
	var attack := MapSiege.by_wave(Vector2i(3, 3), StrikeSamples.lair(), StrikeSamples.fight([5], [1]), true)
	_scene.siege(attack, _done)
	var effect := _scene.effects.current as SiegeEffect
	assert_not_null(effect)
	assert_eq(effect.geometry.place, Vector2i(3, 3))
	assert_eq(effect.get_parent(), _scene.effects)
	_scene.effects.finish()
	assert_eq(_ended, 1)


func test_without_a_level_the_siege_is_over_at_once() -> void:
	var attack := MapSiege.by_wave(Vector2i(3, 3), StrikeSamples.lair(), StrikeSamples.fight([5], [1]), true)
	_scene.siege(attack, _done)
	assert_eq(_ended, 1)
	_scene.siege(attack)
	assert_false(_scene.effects.is_playing())


func _level() -> MapLevelState:
	var state := level_of(8, 8, [Vector2i(1, 1), Vector2i(3, 3)])
	put(state, 3, 3, Content.RESOURCE_BONUS)
	return state
