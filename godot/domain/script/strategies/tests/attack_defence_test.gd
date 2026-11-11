extends TestCase
## test/domain/script/strategies/attack_defence_test.dart: a player recruits
## against the attacks it is warned of.

const HARPOONIST := UnitType.Value.HARPOONIST

var _planner := ArmyPlanner.new()


func _attacked(rich: bool) -> Game:
	var game := AssaultSamples.announce_game()
	var human := game.human_player()
	AssaultSamples.set_level(human, BuildingType.Value.BARRACKS, 5)
	AssaultSamples.station(human, {HARPOONIST: 2})
	for r: ResourceType.Value in ResourceType.Value.values():
		human.resources[r].amount = 50000 if rich else 0
	human.raid_state.attacks.append(
		AnnouncedAttack.new(AssaultSamples.rival_of(game).id, {HARPOONIST: 12}, game.turn + 2, 1)
	)
	return game


func _turn(game: Game) -> ScriptTurn:
	return ScriptTurn.new(game, DartRandom.new(1), [])


func test_a_player_recruits_to_hold_a_base_attack_that_is_announced() -> void:
	var game := _attacked(true)
	var before := AssaultSamples.standing(game.human_player(), HARPOONIST)

	BattleMoves.defend_attacks(_turn(game), _planner)

	assert_true(AssaultSamples.standing(game.human_player(), HARPOONIST) > before)


func test_without_an_announced_attack_it_recruits_nothing() -> void:
	var game := _attacked(true)
	game.human_player().raid_state.attacks.clear()

	BattleMoves.defend_attacks(_turn(game), _planner)

	assert_eq(AssaultSamples.standing(game.human_player(), HARPOONIST), 2)


func test_a_player_with_nothing_to_spend_does_what_it_can() -> void:
	var game := _attacked(false)

	assert_false(BattleMoves.defend_attacks(_turn(game), _planner))
	assert_eq(AssaultSamples.standing(game.human_player(), HARPOONIST), 2)


func test_the_careful_strategy_holds_the_attacks_it_is_warned_of() -> void:
	var game := _attacked(true)

	ConquestStrategy.new().play_turn(_turn(game))

	assert_true(AssaultSamples.standing(game.human_player(), HARPOONIST) > 2)
