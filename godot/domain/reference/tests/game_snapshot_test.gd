extends TestCase
## test/domain/reference/game_snapshot_test.dart. The tests of a change of
## each section, which Dart generates in a loop, are one test that loops
## (SectionChanges); where Dart throws on a level no section holds, the
## snapshot logs an error and gives nothing.

const Personality := FactionPersonality.Value


func _new_game() -> Game:
	var personalities: Array[Personality] = [Personality.PEARL_ORDER, Personality.WRECK_PILLAGERS]
	return GameFactory.new_game("Nemo", 7, Difficulty.Value.NORMAL, false, 0, personalities)


func _changed(before: Dictionary[String, String], after: Dictionary[String, String]) -> Array[String]:
	var found: Array[String] = []
	for name: String in before:
		if before[name] != after.get(name):
			found.append(name)
	return found


func test_two_games_in_the_same_state_give_the_same_texts_though_the_id_of_the_human_differs() -> void:
	var a := _new_game()
	var b := _new_game()
	assert_ne(a.human_player_id, b.human_player_id)
	assert_eq(GameSnapshot.texts(a), GameSnapshot.texts(b))


func test_lists_every_section_by_name() -> void:
	assert_eq(GameSnapshot.texts(_new_game()).keys(), Array(SnapshotSections.names()))
	assert_eq(GameSnapshot.sections(_new_game()).keys(), Array(SnapshotSections.names()))


func test_the_changes_below_cover_every_section() -> void:
	var covered: Array[String] = []
	covered.assign(SectionChanges.all().keys())
	CanonicalKeys.sort(covered)
	assert_eq(covered, SnapshotSections.names())


func test_a_change_of_a_section_changes_that_section_alone() -> void:
	var before := GameSnapshot.texts(_new_game())
	var changes := SectionChanges.all()
	for section: String in changes:
		for i: int in changes[section].size():
			var game := _new_game()
			var change: Callable = changes[section][i]
			change.call(game)
			assert_eq(_changed(before, GameSnapshot.texts(game)), [section] as Array[String], "%s change %d" % [section, i])


func test_reading_a_game_twice_gives_the_same_texts_and_changes_nothing() -> void:
	var game := _new_game()
	var first := GameSnapshot.texts(game)
	assert_eq(GameSnapshot.texts(game), first)
	assert_eq(game.human_player().saved_intel, {} as Dictionary[String, BaseIntel])


func test_never_writes_the_id_drawn_for_the_human() -> void:
	var game := _new_game()
	var changes := SectionChanges.all()
	for section: String in ["map1", "intel", "raids"]:
		for change: Callable in changes[section]:
			change.call(game)
	var texts := GameSnapshot.texts(game)
	assert_false("".join(texts.values()).contains(game.human_player_id))
	assert_true(texts["map1"].contains('"collectedBy":"human"'))
	assert_true(texts["players"].begins_with('[["human",{"baseX":'))
	assert_true(texts["intel"].contains('[["human",{"army":[["scout",2]]'))
	assert_true(texts["raids"].contains('"postAttackTurns":[["human",3]]'))
	assert_true(texts["raids"].contains('"attackerId":"faction-pearlOrder"'))


func test_a_level_not_generated_yet_is_null_a_game_without_faction_starts_with_the_first_one_only() -> void:
	var texts := GameSnapshot.texts(GameFactory.new_game("Nemo", 7))
	assert_true(texts["map1"].begins_with('{"cells":[{"collectedBy":null,'), texts["map1"].left(40))
	assert_eq(texts["map2"], "null")
	assert_eq(texts["map3"], "null")


func test_a_level_no_section_holds_fails_loudly() -> void:
	var game := _new_game()
	game.levels[4] = GameMap.new(0, 0, [], 0)
	expect_error("no section for the level 4")
	assert_eq(GameSnapshot.texts(game), {} as Dictionary[String, String])


func test_the_digests_follow_the_sections_through_the_digest_given() -> void:
	var game := _new_game()
	var expected := PackedStringArray()
	for text: String in GameSnapshot.texts(game).values():
		expected.append("h%d" % text.length())
	assert_eq(GameSnapshot.digests(game, func(text: String) -> String: return "h%d" % text.length()), expected)


func test_a_section_reads_as_specified() -> void:
	var texts := GameSnapshot.texts(_new_game())
	assert_eq(texts["game"], '{"difficulty":"normal","factions":["pearlOrder","wreckPillagers"],'
		+ '"humanPlayerId":"human","status":"playing","turn":1}')
	assert_eq(texts["worksite"], '[["human",{"worksite":{"research":0,"upgrades":0}}],'
		+ '["faction-pearlOrder",{"worksite":{"research":0,"upgrades":0}}],'
		+ '["faction-wreckPillagers",{"worksite":{"research":0,"upgrades":0}}]]')
	assert_eq(texts["journal"], '{"replay":{"actions":[],"endTurnSeeds":[],"exact":true,"mapSeed":7,'
		+ '"playerName":"Nemo"}}')
	assert_true(texts["resources"].begins_with('[["human",{"resources":[["algae",{"amount":100,"maxStorage":5000,'
		+ '"type":"algae"}],["coral",'), texts["resources"].left(80))


## Not in the Dart file: a level 0 is let through, as Dart's `orElse`
## does, and written in no section.
func test_a_level_0_is_written_nowhere() -> void:
	var game := _new_game()
	var before := GameSnapshot.texts(game)
	game.levels[0] = GameMap.new(0, 0, [], 0)
	assert_eq(GameSnapshot.texts(game), before)


## Not in the Dart file: a journal that holds moves and seeds, each move the
## pairs of its JSON in their order, as Dart's GameSnapshot wrote it.
func test_a_journal_reads_as_dart_writes_it() -> void:
	var game := _new_game()
	game.replay.actions[2] = [
		'{"do":"fight","units":{"scout":1,"guardian":2},"player":"faction-pearlOrder"}',
	] as Array[String]
	game.replay.end_turn_seeds[1] = 5
	game.replay.end_turn_seeds[2] = 8
	assert_eq(GameSnapshot.texts(game)["journal"], '{"replay":{"actions":[[2,[[["do","fight"],["units",'
		+ '[["scout",1],["guardian",2]]],["player","faction-pearlOrder"]]]]],"endTurnSeeds":[[1,5],[2,8]],'
		+ '"exact":true,"mapSeed":7,"playerName":"Nemo"}}')
