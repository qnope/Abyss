extends TestCase
## Not in the Dart files: the steps of ActionExecutor and the defaults of
## Action, on actions of the test alone. The Dart tests of the executor go
## through UpgradeBuildingAction (action_executor_test.gd,
## action_executor_history_test.gd).


class _Noisy extends Action:
	var refused: Variant
	var executed := 0

	func _init(refused_: Variant = null) -> void:
		refused = refused_

	func type() -> ActionType.Value:
		return ActionType.Value.EXPLORE

	func description() -> String:
		return "noisy"

	func validate(_game: Game, _player: Player) -> ActionResult:
		return ActionResult.new(refused)

	func execute(_game: Game, _player: Player) -> ActionResult:
		executed += 1
		return ActionResult.success()

	func make_history_entry(_game: Game, _player: Player, _result: ActionResult, turn: int) -> HistoryEntry:
		return ExploreEntry.new(turn, 1, 2)

	func noise_made(_player: Player) -> int:
		return 4


class _Quiet extends Action:
	func type() -> ActionType.Value:
		return ActionType.Value.EXPLORE

	func description() -> String:
		return "quiet"

	func validate(_game: Game, _player: Player) -> ActionResult:
		return ActionResult.success()

	func execute(_game: Game, _player: Player) -> ActionResult:
		return ActionResult.success()


func test_a_success_keeps_its_entry_at_the_turn_and_adds_its_noise() -> void:
	var player := GameSamples.player("p")
	var game := GameSamples.game([player])
	game.turn = 6
	var noise := player.raid_state.noise
	var result := ActionExecutor.new().execute(_Noisy.new(), game, player)
	assert_true(result.is_success)
	assert_eq(player.history_entries.size(), 1)
	assert_eq(player.history_entries[0].turn, 6)
	assert_eq(player.raid_state.noise, noise + 4)


func test_a_refusal_is_answered_before_executing() -> void:
	var player := GameSamples.player("p")
	var game := GameSamples.game([player])
	var action := _Noisy.new(ActionFailure.Value.GAME_OVER)
	var result := ActionExecutor.new().execute(action, game, player)
	assert_eq(result.reason, ActionFailure.Value.GAME_OVER)
	assert_eq(action.executed, 0)
	assert_true(player.history_entries.is_empty())


func test_the_defaults_keep_no_entry_and_make_no_noise() -> void:
	var player := GameSamples.player("p")
	var game := GameSamples.game([player])
	var noise := player.raid_state.noise
	var action := _Quiet.new()
	assert_true(ActionExecutor.new().execute(action, game, player).is_success)
	assert_true(player.history_entries.is_empty())
	assert_eq(player.raid_state.noise, noise)
	assert_eq([action.type(), action.description()], [ActionType.Value.EXPLORE, "quiet"])
