extends TestCase
## test/domain/action/attack_volcanic_kernel_history_test.dart: the history
## entry of an assault on the volcanic kernel. Its check of the subtitle
## never comes: the port drops the field (CaptureEntry).

const ADMIRAL := UnitType.Value.ABYSS_ADMIRAL
const BREAKER := UnitType.Value.DOME_BREAKER
const SCOUT := UnitType.Value.SCOUT


func _action(units: Dictionary[UnitType.Value, int], random: DartRandom = null) -> AttackVolcanicKernelAction:
	return AttackVolcanicKernelAction.new(1, 1, 3, units, random)


func test_make_history_entry_returns_capture_entry_when_captured() -> void:
	var game := SiegeSamples.kernel_game({ADMIRAL: 1, BREAKER: 240})
	var action := _action({ADMIRAL: 1, BREAKER: 240}, DartRandom.new(0))
	var result := action.execute(game, game.human_player())
	var r: AttackVolcanicKernelResult = result
	assert_true(r.captured)

	var entry := action.make_history_entry(game, game.human_player(), result, 5)
	assert_true(entry is CaptureEntry)
	var capture: CaptureEntry = entry
	assert_eq(capture.turn, 5)
	assert_true(capture.is_volcanic_kernel())


func test_make_history_entry_returns_null_when_not_captured() -> void:
	var game := SiegeSamples.kernel_game({ADMIRAL: 1, SCOUT: 1})
	var action := _action({ADMIRAL: 1, SCOUT: 1}, DartRandom.new(0))
	var result := action.execute(game, game.human_player())
	var r: AttackVolcanicKernelResult = result
	assert_false(r.captured)

	assert_null(action.make_history_entry(game, game.human_player(), result, 5))


## Not in the Dart file: a victory whose admiral fell is written down, not
## captured; another action's result, or a result without its fight, none.
func test_make_history_entry_writes_a_victory_without_capture() -> void:
	var game := SiegeSamples.kernel_game({ADMIRAL: 1, BREAKER: 120})
	var action := _action({ADMIRAL: 1, BREAKER: 120}, DartRandom.new(52))
	var entry: CaptureEntry = action.make_history_entry(game, game.human_player(), action.execute(game, game.human_player()), 7)
	assert_eq([entry.turn, entry.captured, entry.transition_base_name], [7, false, CaptureEntry.VOLCANIC_KERNEL])
	assert_null(action.make_history_entry(game, game.human_player(), ActionResult.success(), 7))
	assert_null(action.make_history_entry(game, game.human_player(), AttackVolcanicKernelResult.success(true), 7))
