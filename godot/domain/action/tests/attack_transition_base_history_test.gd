extends TestCase
## test/domain/action/attack_transition_base_history_test.dart: the history
## entry of an assault on the Faille of SiegeSamples.attack_game.

const ADMIRAL := UnitType.Value.ABYSS_ADMIRAL


## The history entry of an assault of `army` on the Faille, fought with the
## dice of `seed_`.
func _entry_of(army: Dictionary[UnitType.Value, int], seed_: int) -> HistoryEntry:
	var game := SiegeSamples.attack_game(army)
	var action := AttackTransitionBaseAction.new(1, 1, 1, army, DartRandom.new(seed_))
	var result := action.execute(game, game.human_player())
	return action.make_history_entry(game, game.human_player(), result, 7)


func test_make_history_entry_records_a_capture() -> void:
	var entry: CaptureEntry = _entry_of({ADMIRAL: 1, UnitType.Value.DOME_BREAKER: 30}, 42)
	assert_true(entry.captured)
	assert_eq(entry.transition_base_name, "Faille")
	assert_eq(entry.turn, 7)


## 12 harpoonists + seed 94: the player wins but the admiral dies.
func test_make_history_entry_records_a_victory_where_the_admiral_fell_not_captured() -> void:
	var entry: CaptureEntry = _entry_of({ADMIRAL: 1, UnitType.Value.HARPOONIST: 12}, 94)
	assert_false(entry.captured)
	assert_eq(entry.transition_base_name, "Faille")


func test_make_history_entry_records_nothing_after_a_defeat() -> void:
	assert_null(_entry_of({ADMIRAL: 1, UnitType.Value.SCOUT: 1}, 42))


## Not in the Dart file: nothing for a result of another action, and no
## name for a victory this action did not fight.
func test_make_history_entry_reads_its_own_results_only() -> void:
	var game := SiegeSamples.attack_game()
	var action := AttackTransitionBaseAction.new(1, 1, 1, {ADMIRAL: 1})
	assert_null(action.make_history_entry(game, game.human_player(), ActionResult.success(), 7))
	var won := AttackTransitionBaseResult.success(true, false, HistorySamples.fight(true))
	var entry: CaptureEntry = action.make_history_entry(game, game.human_player(), won, 7)
	assert_eq(entry.transition_base_name, "")
	assert_null(action.make_history_entry(game, game.human_player(), AttackTransitionBaseResult.success(true), 7))
