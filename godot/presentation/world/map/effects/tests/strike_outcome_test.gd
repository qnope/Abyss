extends StrikeEffectCase
## What a strike leaves: each hit flashes the target and shakes the camera, then
## the monster falls or the army falls back, a place taken lights up.


func test_a_hit_flashes_the_target_white_and_shakes_the_camera() -> void:
	var effect := _effect()
	effect.advance(effect.timeline.pace().hit_at(0) + 0.01)
	assert_true(effect.jolt() != 0.0)
	assert_true(_overlay().r > 0.99 and _overlay().a > 0.0)
	assert_true(effect.losses.dealt.visible)
	assert_eq(effect.losses.dealt.text, "−7")
	assert_true(effect.losses.taken.visible)
	assert_eq(effect.losses.taken.text, "−2")


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
	assert_null(_content_made.material_overlay, "and the place wears what it wore: the map keeps its node")


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
