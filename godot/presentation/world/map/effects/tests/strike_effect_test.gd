extends TestCase
## An attack played on the map: the army swims to the lair and lunges once per
## round, each hit flashes and shakes, then the monster falls or the army retreats.

const Hard := MonsterDifficulty.Value

var _made: Array[Node] = []
var _content_made: MeshInstance3D


func after_each() -> void:
	for node in _made:
		node.free()


func _effect(victory := true, lair: MonsterLair = null, span := 1) -> StrikeEffect:
	var strike := StrikeSamples.strike(Vector2i(3, 3), victory, lair, span)
	var geometry := StrikeGeometry.new(Vector2i(0, 5), strike.target, 8, 8, span)
	return _mount(StrikeEffect.new(strike, geometry, _content()))


func _mount(effect: StrikeEffect) -> StrikeEffect:
	(Engine.get_main_loop() as SceneTree).root.add_child(effect)
	_made.append(effect)
	return effect


func _content() -> Node3D:
	var content := Node3D.new()
	_content_made = MeshInstance3D.new()
	_content_made.mesh = BoxMesh.new()
	content.add_child(_content_made)
	_made.append(content)
	return content


func _overlay() -> Color:
	return (_content_made.material_overlay as StandardMaterial3D).albedo_color


func _lair() -> MonsterLair:
	return StrikeSamples.lair(MonsterFamily.Value.HUNTER)


func test_it_lasts_as_long_as_the_timeline() -> void:
	var effect := _effect()
	assert_eq(effect.duration(), effect.timeline.total())
	assert_true(effect.duration() > effect.timeline.swim)


func test_a_place_has_no_monster_and_the_army_stands_where_it_set_off() -> void:
	var effect := _effect()
	assert_null(effect.monster)
	assert_eq(effect.squad.position, MapGrid.at(0, 5, 8, 8))


func test_a_lair_has_its_monster_standing_toward_the_army_and_facing_it() -> void:
	var effect := _effect(true, _lair())
	assert_not_null(effect.monster)
	assert_eq(effect.monster.get_parent(), effect)
	var toward := (MapGrid.at(effect.geometry.approach().x, effect.geometry.approach().y, 8, 8)
		- effect.geometry.lair()).normalized()
	assert_almost_eq(effect.monster.position.distance_to(effect.geometry.lair() + toward * StrikeEffect.STAND_OUT), 0.0, 1e-5)


func test_the_army_swims_to_the_cell_beside_the_lair_and_lunges_at_it() -> void:
	var effect := _effect()
	var rest := MapGrid.at(effect.geometry.approach().x, effect.geometry.approach().y, 8, 8)
	effect.advance(effect.timeline.swim)
	assert_almost_eq(effect.squad.position.distance_to(rest), 0.0, 1e-4)
	effect.advance(effect.timeline.pace().lunge() / 2.0)
	assert_true(effect.squad.position.distance_to(effect.geometry.lair()) < rest.distance_to(effect.geometry.lair()))


func test_the_figures_play_their_animations_in_order() -> void:
	var effect := _effect(true, _lair())
	effect.advance(effect.timeline.swim + 0.01)
	var player := effect.squad.figures[0].find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	assert_eq(player.current_animation, "attack")
	effect.advance(effect.timeline.pace().lunge() / 2.0)
	var hit := effect.monster.models[0].find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	assert_eq(hit.current_animation, "hit")


func test_a_hit_flashes_the_target_white_and_shakes_the_camera() -> void:
	var effect := _effect()
	effect.advance(effect.timeline.pace().hit_at(0) + 0.01)
	assert_true(effect.jolt() != 0.0)
	assert_true(_overlay().r > 0.99 and _overlay().a > 0.0)
	assert_true(effect.dealt.visible)
	assert_eq(effect.dealt.text, "−7")
	assert_true(effect.taken.visible)
	assert_eq(effect.taken.text, "−2")


func test_a_place_taken_lights_up_in_cyan_between_the_blows_and_the_end() -> void:
	var effect := _effect(true)
	effect.advance(effect.timeline.pace().end() + effect.timeline.pace().lunge())
	effect.advance(StrikeEffect.FLASH_LENGTH)
	var outcome := effect.timeline.outcome_at(effect.elapsed)
	assert_true(outcome > 0.0 and outcome < 1.0, "in the middle of the outcome")
	assert_almost_eq(_overlay().g, MapPalette.CAPTURE.g, 1e-4)
	effect.finish()
	assert_true(effect.is_done)
	assert_eq(effect.jolt(), 0.0, "rests at the end")


func test_a_place_not_taken_does_not_light_up() -> void:
	var effect := _effect(false)
	effect.advance(effect.duration() - 0.001)
	assert_null(_content_made.material_overlay)


func test_a_beaten_monster_rolls_over_and_shrinks_into_its_foot() -> void:
	var effect := _effect(true, _lair())
	effect.advance(effect.duration() - 0.001)
	assert_true(effect.monster.scale.x < 1.0)
	effect.finish()
	assert_false(effect.monster.visible)


func test_a_monster_that_wins_stays_and_the_army_falls_back() -> void:
	var effect := _effect(false, _lair())
	effect.advance(effect.timeline.pace().end() + 0.01)
	var before := effect.squad.position
	effect.advance(effect.duration())
	assert_true(effect.monster.visible)
	assert_eq(effect.monster.rotation.z, 0.0)
	assert_true(effect.squad.position != before)
	assert_true(effect.squad.scale.x < 0.01, "the army shrinks away at the end")


func test_a_place_of_several_cells_is_attacked_at_its_middle() -> void:
	var effect := _effect(true, null, 2)
	assert_eq(effect.geometry.lair(), MapGrid.at(3, 3, 8, 8) + Vector3(1.0, 0.0, 1.0) * MapGrid.CELL / 2.0)


func test_without_a_content_it_still_plays() -> void:
	var strike := StrikeSamples.strike()
	var effect := _mount(StrikeEffect.new(strike, StrikeGeometry.new(Vector2i(3, 5), strike.target, 8, 8)))
	effect.advance(effect.duration() + 1.0)
	assert_true(effect.is_done)
