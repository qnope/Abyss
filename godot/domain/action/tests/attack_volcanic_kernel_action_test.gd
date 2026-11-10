extends TestCase
## test/domain/action/attack_volcanic_kernel_action_test.dart: whether an
## assault on the guardians of the volcanic kernel may start.

const ADMIRAL := UnitType.Value.ABYSS_ADMIRAL
const BREAKER := UnitType.Value.DOME_BREAKER
const SCOUT := UnitType.Value.SCOUT


func _action(units: Dictionary[UnitType.Value, int], random: DartRandom = null) -> AttackVolcanicKernelAction:
	return AttackVolcanicKernelAction.new(1, 1, 3, units, random)


func test_validate_fails_when_map_is_null() -> void:
	var game := SiegeSamples.kernel_game({ADMIRAL: 1, BREAKER: 10})
	game.levels.clear()
	var result := _action({ADMIRAL: 1, BREAKER: 5}).validate(game, game.human_player())
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.MAP_NOT_GENERATED)


func test_validate_fails_when_cell_is_not_volcanic_kernel() -> void:
	var game := SiegeSamples.kernel_game({ADMIRAL: 1, BREAKER: 10}, null, CellContentType.Value.EMPTY)
	var result := _action({ADMIRAL: 1, BREAKER: 5}).validate(game, game.human_player())
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.NO_VOLCANIC_KERNEL_HERE)


func test_validate_fails_when_kernel_already_captured() -> void:
	var game := SiegeSamples.kernel_game({ADMIRAL: 1, BREAKER: 10}, "someone")
	var result := _action({ADMIRAL: 1, BREAKER: 5}).validate(game, game.human_player())
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.KERNEL_ALREADY_CAPTURED)


func test_validate_fails_without_abyss_admiral() -> void:
	var game := SiegeSamples.kernel_game({BREAKER: 10})
	var result := _action({BREAKER: 5}).validate(game, game.human_player())
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.ADMIRAL_REQUIRED)


func test_validate_fails_when_units_exceed_stock() -> void:
	var game := SiegeSamples.kernel_game({ADMIRAL: 1, BREAKER: 2})
	var result := _action({ADMIRAL: 1, BREAKER: 10}).validate(game, game.human_player())
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.NOT_ENOUGH_UNITS)


func test_validate_succeeds_on_valid_scenario() -> void:
	var game := SiegeSamples.kernel_game({ADMIRAL: 1, BREAKER: 50})
	assert_true(_action({ADMIRAL: 1, BREAKER: 50}).validate(game, game.human_player()).is_success)


## Not in the Dart file: its type, its words, its noise, an army with none
## of a type, the failure a result gives, and a refused assault leaves the
## stock as it was.
func test_names_itself_makes_the_noise_of_a_fight_and_refuses_cleanly() -> void:
	var game := SiegeSamples.kernel_game({ADMIRAL: 1, BREAKER: 2})
	var player := game.human_player()
	var action := _action({ADMIRAL: 1, BREAKER: 0, SCOUT: -2})
	assert_eq(action.type(), ActionType.Value.ATTACK_VOLCANIC_KERNEL)
	assert_eq(action.description(), "Assaut Noyau Volcanique")
	assert_eq(action.noise_made(player), NoiseRules.PER_FIGHT)
	assert_true(action.validate(game, player).is_success)
	var refused := _action({ADMIRAL: 1, BREAKER: 3}).execute(game, player)
	assert_eq(refused.reason, ActionFailure.Value.NOT_ENOUGH_UNITS)
	assert_eq(player.unit_counts_on_level(3), {ADMIRAL: 1, BREAKER: 2})
	var failed := AttackVolcanicKernelResult.failure(ActionFailure.Value.ADMIRAL_REQUIRED)
	assert_eq([failed.victory, failed.captured, failed.fight, failed.sent, failed.wounded], [false, false, null, {}, {}])
	assert_null(action.make_history_entry(game, player, refused, 5))
