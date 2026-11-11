extends TestCase
## test/domain/script/strategies/contest_moves_test.dart: a player takes
## what the factions hold.


static func _turn_of(game: Game, player: Player) -> ScriptTurn:
	return ScriptTurn.new(game, DartRandom.new(1), [], player)


func test_a_player_takes_the_weakly_held_post_of_a_faction_it_has_seen() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE)
	war.arm(war.human())
	war.put(war.owner(), war.below(), PostWar.GARRISON)

	assert_true(ContestMoves.contest(_turn_of(war.game, war.human())))
	assert_eq(war.post.captured_by, war.human().id)


func test_it_leaves_a_post_it_would_not_beat() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE)
	war.arm(war.human(), {})
	war.put(war.human(), war.level, {})
	war.put(war.owner(), war.below(), PostWar.WALL)

	assert_false(ContestMoves.contest(_turn_of(war.game, war.human())))
	assert_eq(war.post.captured_by, war.owner().id)


func test_a_player_besieges_a_weakly_garrisoned_kernel() -> void:
	var war := KernelWar.new(1)
	war.put(war.human(), KernelGarrison.VOLCANO_LEVEL, KernelWar.HORDE)
	war.garrison(KernelWar.SMALL_GARRISON)

	assert_true(ContestMoves.contest(_turn_of(war.game, war.human())))
	assert_eq(war.holder(), war.human().id)


func test_a_player_besieges_a_kernel_held_high_with_no_faction_cap() -> void:
	var war := KernelWar.new(9)
	war.put(war.human(), KernelGarrison.VOLCANO_LEVEL, KernelWar.HORDE)
	war.garrison(KernelWar.SMALL_GARRISON)

	assert_true(ContestMoves.contest(_turn_of(war.game, war.human())))
	assert_eq(war.kernel_of(war.owner()), 8)


func test_with_nothing_held_by_others_there_is_nothing_to_contest() -> void:
	var war := KernelWar.new(1)
	war.put(war.human(), KernelGarrison.VOLCANO_LEVEL, KernelWar.HORDE)
	war.garrison(KernelWar.SMALL_GARRISON)
	for id: String in war.game.players.keys():
		if id != war.human().id:
			war.game.players.erase(id)

	assert_false(ContestMoves.contest(_turn_of(war.game, war.human())))
