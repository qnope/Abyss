extends TestCase
## test/domain/action/attack_base/attack_base_validate_test.dart: whether a
## player may attack the base of another.

const HARPOONIST := UnitType.Value.HARPOONIST
const HORDE := AssaultSamples.HORDE


func _reason(action: AttackBaseAction, game: Game, player: Player) -> Variant:
	return action.validate(game, player).reason


func test_a_revealed_rival_base_can_be_attacked_with_units_of_the_base() -> void:
	var game := AssaultSamples.assault_game()
	AssaultSamples.station(game.human_player(), HORDE)
	assert_true(AssaultSamples.strike(game, HORDE).validate(game, game.human_player()).is_success)


func test_the_human_can_be_named_as_a_target_without_its_id() -> void:
	var game := AssaultSamples.assault_game()
	var rival := AssaultSamples.rival_of(game)
	AssaultSamples.station(rival, HORDE)
	var named := AttackBaseAction.new(AttackBaseAction.HUMAN, HORDE)
	assert_true(named.validate(game, rival).is_success)
	AssaultSamples.station(game.human_player(), HORDE)
	assert_eq(_reason(named, game, game.human_player()), ActionFailure.Value.CANNOT_ATTACK_SELF)


func test_a_player_cannot_attack_itself() -> void:
	var game := AssaultSamples.assault_game()
	AssaultSamples.station(game.human_player(), HORDE)
	var self_ := AttackBaseAction.new(game.human_player().id, HORDE)
	assert_eq(_reason(self_, game, game.human_player()), ActionFailure.Value.CANNOT_ATTACK_SELF)


func test_an_unknown_player_cannot_be_attacked() -> void:
	var game := AssaultSamples.assault_game()
	AssaultSamples.station(game.human_player(), HORDE)
	var ghost := AttackBaseAction.new("nobody", HORDE)
	assert_eq(_reason(ghost, game, game.human_player()), ActionFailure.Value.NO_SUCH_PLAYER)


func test_a_fallen_player_is_out_of_reach() -> void:
	var game := AssaultSamples.assault_game()
	AssaultSamples.station(game.human_player(), HORDE)
	AssaultSamples.rival_of(game).saved_fallen = true
	assert_eq(_reason(AssaultSamples.strike(game, HORDE), game, game.human_player()), ActionFailure.Value.PLAYER_FALLEN)


func test_the_human_must_have_seen_the_base() -> void:
	var game := AssaultSamples.assault_game(12, false)
	AssaultSamples.station(game.human_player(), HORDE)
	assert_eq(_reason(AssaultSamples.strike(game, HORDE), game, game.human_player()), ActionFailure.Value.BASE_NOT_REVEALED)


func test_a_faction_attacks_a_base_its_strategy_knows_without_the_fog() -> void:
	var game := AssaultSamples.assault_game(12, false)
	var rival := AssaultSamples.rival_of(game)
	AssaultSamples.station(rival, HORDE)
	var action := AttackBaseAction.new(game.human_player().id, HORDE)
	assert_true(action.validate(game, rival).is_success)


func test_the_army_must_exist_and_not_be_empty() -> void:
	var game := AssaultSamples.assault_game()
	var human := game.human_player()
	AssaultSamples.station(human, {HARPOONIST: 3})
	assert_eq(_reason(AssaultSamples.strike(game, {HARPOONIST: 4}), game, human), ActionFailure.Value.NOT_ENOUGH_UNITS)
	assert_eq(_reason(AssaultSamples.strike(game, {HARPOONIST: 0}), game, human), ActionFailure.Value.NO_UNIT_SELECTED)


func test_units_of_the_deeper_levels_cannot_attack() -> void:
	var game := AssaultSamples.assault_game()
	AssaultSamples.station(game.human_player(), {})
	assert_eq(_reason(AssaultSamples.strike(game, {HARPOONIST: 1}), game, game.human_player()), ActionFailure.Value.NOT_ENOUGH_UNITS)


func test_the_refusal_is_told_before_any_army_is_chosen() -> void:
	var game := AssaultSamples.assault_game()
	var human := game.human_player()
	assert_null(AttackBaseValidator.refusal(game, human, AssaultSamples.rival_of(game).id))
	assert_eq(AttackBaseValidator.refusal(game, human, human.id), ActionFailure.Value.CANNOT_ATTACK_SELF)
	var early := AssaultSamples.assault_game(9)
	assert_eq(AttackBaseValidator.refusal(early, early.human_player(), AssaultSamples.rival_of(early).id),
		ActionFailure.Value.ATTACK_TOO_EARLY)
	var unseen := AssaultSamples.assault_game(12, false)
	assert_eq(AttackBaseValidator.refusal(unseen, unseen.human_player(), AssaultSamples.rival_of(unseen).id),
		ActionFailure.Value.BASE_NOT_REVEALED)
