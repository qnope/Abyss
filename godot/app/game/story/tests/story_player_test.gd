extends StoryFlowCase
## lib/presentation/screens/game/game_screen_story.dart, `tellTurnStory`: the
## chapters played on the map one after the other, the level of each opened,
## and the skip.


func test_the_chapters_play_one_after_the_other_each_on_its_level() -> void:
	var player := player_of(story_of_three())
	player.play()
	assert_eq(world.map.level, 1)
	assert_true(world.map.effects.current is SiegeEffect)
	run_effect()
	assert_eq(world.map.level, VOLCANO, "the second chapter is on the volcano's level")
	assert_true(world.map.effects.current is SiegeEffect)
	assert_eq(told, 0)
	run_effect()
	assert_eq(world.map.level, 1)
	assert_false(player.is_over())
	run_effect()
	assert_true(player.is_over())
	assert_eq(told, 1)
	assert_false(world.map.effects.is_playing())


func test_a_story_with_no_chapter_is_over_at_once() -> void:
	var player := player_of(TurnStory.new())
	player.play()
	assert_eq(told, 1)


func test_skipping_finishes_the_effect_and_plays_no_other_chapter() -> void:
	var player := player_of(story_of_three())
	player.play()
	var effect := world.map.effects.current
	player.skip()
	assert_true(effect.is_done, "its last moment is shown")
	assert_false(world.map.effects.is_playing())
	assert_eq(world.map.level, 1, "the map is left as it is")
	assert_eq(told, 1)
	assert_true(player.is_over())


func test_the_story_is_told_once_however_often_it_is_skipped() -> void:
	var player := player_of(story_of_three())
	player.play()
	player.skip()
	player.skip()
	assert_eq(told, 1)


func test_a_cancelled_story_plays_and_tells_nothing() -> void:
	var player := player_of(story_of_three())
	player.play()
	player.cancel()
	player.skip()
	run_effect()
	assert_eq(told, 0)
	assert_false(world.map.effects.is_playing())


func test_the_map_tab_opens_for_the_story() -> void:
	press("Base")
	var player := player_of(story_of_three())
	player.play()
	assert_eq(hud.tab, GameTab.Value.MAP)
	assert_eq(world.view, WorldHost.View.MAP)
	assert_true(world.map.effects.current is SiegeEffect, "played over the map shown")


func test_a_level_already_shown_is_not_drawn_again() -> void:
	scout_sees()
	session.changed.emit()
	var lift := world.map.effects.current
	assert_true(lift is FogLift)
	controller.map.tell_level(1)
	assert_eq(world.map.effects.current, lift, "the lift is not cut")


func test_the_fog_chapter_waits_for_the_fog_the_map_lifts() -> void:
	scout_sees()
	session.changed.emit()
	var story := TurnStory.new()
	story.chapters.append(StoryChapter.fog(1, [] as Array[Vector2i], [] as Array[Vector2i]))
	story.chapters.append(siege_on(1, Vector2i(human.base_x, human.base_y)))
	var player := player_of(story)
	player.play()
	assert_true(world.map.effects.current is FogLift)
	run_effect()
	assert_true(world.map.effects.current is SiegeEffect, "the siege follows the lift")
	run_effect()
	assert_eq(told, 1)


func test_a_fog_chapter_with_no_fog_to_lift_goes_on_at_once() -> void:
	var story := TurnStory.new()
	story.chapters.append(StoryChapter.fog(1, [] as Array[Vector2i], [] as Array[Vector2i]))
	var player := player_of(story)
	player.play()
	assert_eq(told, 1)
