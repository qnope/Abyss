extends TestCase
## test/domain/action/attack_volcanic_kernel_execute_test.dart: an assault on
## the guardians of the volcanic kernel, won or lost, with the admiral
## standing or fallen, to the last die of the seeds of the Dart tests.

const ADMIRAL := UnitType.Value.ABYSS_ADMIRAL
const BREAKER := UnitType.Value.DOME_BREAKER
const SCOUT := UnitType.Value.SCOUT


func _action(units: Dictionary[UnitType.Value, int], random: DartRandom = null) -> AttackVolcanicKernelAction:
	return AttackVolcanicKernelAction.new(1, 1, 3, units, random)


func test_execute_victory_with_admiral_alive_captures_the_kernel() -> void:
	var game := SiegeSamples.kernel_game({ADMIRAL: 1, BREAKER: 240})
	var r: AttackVolcanicKernelResult = _action({ADMIRAL: 1, BREAKER: 240}, DartRandom.new(0)).execute(game, game.human_player())
	assert_true(r.is_success)
	assert_true(r.victory)
	assert_true(r.captured)

	var cell := game.levels[3].cell_at(1, 1)
	assert_true(cell.is_collected())
	assert_eq(cell.collected_by, "test-uuid")


func test_execute_victory_with_admiral_dead_does_not_capture() -> void:
	var game := SiegeSamples.kernel_game({ADMIRAL: 1, BREAKER: 120})
	var r: AttackVolcanicKernelResult = _action({ADMIRAL: 1, BREAKER: 120}, DartRandom.new(52)).execute(game, game.human_player())
	assert_true(r.victory)
	assert_false(r.captured)

	assert_false(game.levels[3].cell_at(1, 1).is_collected())


func test_execute_defeat_loses_units_and_does_not_capture() -> void:
	var game := SiegeSamples.kernel_game({ADMIRAL: 1, SCOUT: 1})
	var r: AttackVolcanicKernelResult = _action({ADMIRAL: 1, SCOUT: 1}, DartRandom.new(0)).execute(game, game.human_player())
	assert_true(r.is_success)
	assert_false(r.victory)
	assert_false(r.captured)

	assert_false(game.levels[3].cell_at(1, 1).is_collected())


func test_execute_casualties_are_properly_resolved() -> void:
	var game := SiegeSamples.kernel_game({ADMIRAL: 1, BREAKER: 240})
	var r: AttackVolcanicKernelResult = _action({ADMIRAL: 1, BREAKER: 240}, DartRandom.new(0)).execute(game, game.human_player())
	assert_false(r.sent.is_empty())
	var total_out := 0
	for counts: Dictionary[UnitType.Value, int] in [r.survivors_intact, r.wounded, r.dead]:
		for count: int in counts.values():
			total_out += count
	var total_sent := 0
	for count: int in r.sent.values():
		total_sent += count
	assert_eq(total_out, total_sent)
