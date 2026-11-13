extends StoryCase
## lib/presentation/screens/game/story/turn_story.dart: what the map tells at the
## end of a turn, and in what order.


func test_a_quiet_turn_has_nothing_to_tell() -> void:
	var story := TurnStory.plan(game, TurnStorySnapshot.of(human), result())
	assert_true(story.is_empty())


func test_the_chapters_come_in_the_order_the_turn_happened() -> void:
	var before := TurnStorySnapshot.of(human)
	see(1, hidden())
	var attacks: Array[FactionAttackReport] = [attack(true), attack(false, null)]
	var story := TurnStory.plan(game, before, result(raid(), raid(false), wave(), attacks))
	assert_false(story.is_empty())
	var kinds: Array[String] = []
	for chapter in story.chapters:
		kinds.append("fog" if chapter.is_fog() else "siege@%d" % chapter.level)
	assert_eq(kinds, ["fog", "siege@1", "siege@1", "siege@3", "siege@1", "siege@1"] as Array[String])
	assert_true(story.chapters[1].siege.victory, "the raid, then the predators lost")
	assert_false(story.chapters[2].siege.victory)


func test_an_attack_no_map_can_place_is_left_out() -> void:
	var attacks: Array[FactionAttackReport] = [attack(true, null, "cheminee:6"), attack(true)]
	var story := TurnStory.plan(game, TurnStorySnapshot.of(human), result(null, null, null, attacks))
	assert_eq(story.chapters.size(), 1)
