extends TestCase
## test/domain/action/spy_base/spy_base_test.dart, group 'the refusals':
## when a Scout may not leave for a base.

const SCOUT := UnitType.Value.SCOUT


func _scene(scout := true) -> Game:
	var game := AssaultSamples.assault_game()
	var scouts: Dictionary[UnitType.Value, int] = {}
	if scout:
		scouts[SCOUT] = 2
	AssaultSamples.station(game.human_player(), scouts)
	return game


func _why(game: Game, target := "") -> Variant:
	var id := AssaultSamples.rival_of(game).id if target.is_empty() else target
	return SpyBaseAction.new(id).validate(game, game.human_player()).reason


func test_the_refusals_a_scout_is_needed() -> void:
	assert_eq(_why(_scene(false)), ActionFailure.Value.NOT_ENOUGH_UNITS)


func test_the_refusals_the_base_must_have_been_seen() -> void:
	var game := AssaultSamples.assault_game(12, false)
	AssaultSamples.station(game.human_player(), {SCOUT: 1})
	assert_eq(_why(game), ActionFailure.Value.BASE_NOT_REVEALED)


func test_the_refusals_one_cannot_spy_on_oneself() -> void:
	var game := _scene()
	assert_eq(_why(game, game.human_player().id), ActionFailure.Value.CANNOT_ATTACK_SELF)


func test_the_refusals_an_unknown_player_cannot_be_spied() -> void:
	assert_eq(_why(_scene(), "nobody"), ActionFailure.Value.NO_SUCH_PLAYER)


func test_the_refusals_a_fallen_base_is_not_worth_a_scout() -> void:
	var game := _scene()
	AssaultSamples.rival_of(game).saved_fallen = true
	assert_eq(_why(game), ActionFailure.Value.PLAYER_FALLEN)


## Not in the Dart file: a refused spy changes nothing, the static refusal
## answers a screen, and the French description names the target.
func test_a_refused_spy_changes_nothing() -> void:
	var game := _scene(false)
	var human := game.human_player()
	var action := SpyBaseAction.new("rival-1")
	assert_eq(action.execute(game, human).reason, ActionFailure.Value.NOT_ENOUGH_UNITS)
	assert_true(human.intel().is_empty())
	var other := _scene()
	assert_null(SpyBaseAction.refusal(other, other.human_player(), "rival-1"))
	assert_eq([action.type(), action.description()], [ActionType.Value.SPY_BASE, "Espionne la base rival-1"])
