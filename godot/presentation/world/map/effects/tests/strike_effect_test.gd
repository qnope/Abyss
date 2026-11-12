extends StrikeEffectCase
## An attack played on the map: the army swims to the lair and lunges once per
## round, the monsters come out and play their animations.


func test_it_lasts_as_long_as_the_timeline() -> void:
	var effect := _effect()
	assert_eq(effect.duration(), effect.timeline.total())
	assert_true(effect.duration() > effect.timeline.swim)


func test_the_lair_stands_hidden_while_its_monsters_are_out_and_back_when_they_are_gone() -> void:
	var effect := _effect(true, _lair())
	var content := _content_made.get_parent() as Node3D
	assert_false(content.visible)
	effect.advance(effect.duration() - 0.01)
	assert_false(content.visible)
	effect.finish()
	assert_true(content.visible)


func test_a_place_attacked_stays_in_sight() -> void:
	var effect := _effect()
	assert_true((_content_made.get_parent() as Node3D).visible)
	effect.advance(effect.duration() / 2.0)
	assert_true((_content_made.get_parent() as Node3D).visible)


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
