extends TestCase
## test/domain/script/assault_moves_test.dart: a script attacks the base of
## another player.

const HARPOONIST := UnitType.Value.HARPOONIST


func _turn_of(game: Game) -> ScriptTurn:
	return ScriptSamples.turn(game)


func test_a_script_attacks_a_given_player_with_the_army_it_picks() -> void:
	var game := AssaultSamples.assault_game()
	AssaultSamples.station(game.human_player(), AssaultSamples.HORDE)

	var done := AssaultMoves.attack_base(_turn_of(game), AssaultSamples.rival_of(game).id, AssaultSamples.HORDE)

	assert_true(done)
	assert_false(AssaultSamples.rival_of(game).history_entries.is_empty())


func test_a_refused_attack_is_just_false_and_plays_nothing() -> void:
	var game := AssaultSamples.assault_game(3)
	AssaultSamples.station(game.human_player(), AssaultSamples.HORDE)

	var done := AssaultMoves.attack_base(_turn_of(game), AssaultSamples.rival_of(game).id, AssaultSamples.HORDE)

	assert_false(done)
	assert_eq(AssaultSamples.standing(game.human_player(), HARPOONIST), 40)


## Not in the Dart file: the attack on a post, the spy and the announced
## attack, whose fight seed a plain Random draws and a SeededRandom gives.
func test_a_script_strikes_a_post_and_sends_a_spy() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE)
	war.arm(war.attacker())
	var turn := ScriptSamples.turn(war.game, war.attacker())
	assert_true(AssaultMoves.attack_post(turn, war.level, war.at.x, war.at.y, PostWar.HORDE))
	assert_eq(war.post.captured_by, war.attacker().id)
	assert_false(AssaultMoves.attack_post(turn, war.level, war.at.x, war.at.y, PostWar.HORDE))
	var game := AssaultSamples.assault_game()
	var rival := AssaultSamples.rival_of(game)
	assert_false(AssaultMoves.spy_on(_turn_of(game), rival.id), "no scout")
	AssaultSamples.station(game.human_player(), {UnitType.Value.SCOUT: 1})
	AssaultSamples.set_level(game.human_player(), BuildingType.Value.BARRACKS, 1)
	assert_true(AssaultMoves.spy_on(_turn_of(game), rival.id))


func test_an_attack_announced_by_a_script_takes_its_seed_as_dart_does() -> void:
	var game := AssaultSamples.announce_game()
	var rival := AssaultSamples.rival_of(game)
	var turn := ScriptSamples.turn(game, rival, 1)
	assert_false(AssaultMoves.announce_attack(turn.as_player(game.human_player()), AssaultSamples.RAIDERS))
	assert_true(AssaultMoves.announce_attack(turn, AssaultSamples.RAIDERS))
	var drawn := DartRandom.new(1).next_int(0x7FFFFFFF)
	assert_eq(game.human_player().raid_state.attacks[0].fight_seed, drawn)
	var other := AssaultSamples.announce_game()
	var seeded := ScriptTurn.new(other, DartRandom.new(9), [], AssaultSamples.rival_of(other))
	assert_true(AssaultMoves.announce_attack(seeded, AssaultSamples.RAIDERS))
	assert_eq(other.human_player().raid_state.attacks[0].fight_seed, 9)
