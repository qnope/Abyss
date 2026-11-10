extends TestCase
## test/domain/action/action_executor_history_test.dart: the history the
## executor keeps.

const HQ := BuildingType.Value.HEADQUARTERS


## Validates, but fails to execute: the branch where the execution fails
## once the validation passed.
class _FailingExecuteAction extends Action:
	func type() -> ActionType.Value:
		return ActionType.Value.UPGRADE_BUILDING

	func description() -> String:
		return "failing execute"

	func validate(_game: Game, _player: Player) -> ActionResult:
		return ActionResult.success()

	func execute(_game: Game, _player: Player) -> ActionResult:
		return ActionResult.failure(ActionFailure.Value.NOT_ENOUGH_RESOURCES)

	func make_history_entry(_game: Game, _player: Player, _result: ActionResult, turn: int) -> HistoryEntry:
		return BuildingEntry.new(turn, BuildingType.Value.HEADQUARTERS, 99)


func _scenario(coral := 80, ore := 50) -> Player:
	return ActionSamples.stocked(ActionSamples.amounts(100, coral, ore, 60, 5), {HQ: 0})


func test_successful_upgrade_building_action_appends_a_building_entry() -> void:
	var player := _scenario()
	var game := ActionSamples.game_of(player, 7)
	assert_true(ActionExecutor.new().execute(UpgradeBuildingAction.new(HQ), game, player).is_success)
	assert_eq(player.history_entries.size(), 1)
	var entry: BuildingEntry = player.history_entries[0]
	assert_eq([entry.turn, entry.building_type, entry.new_level], [7, HQ, 1])


func test_failed_validation_does_not_append_a_history_entry() -> void:
	var player := _scenario(10, 5)
	var result := ActionExecutor.new().execute(UpgradeBuildingAction.new(HQ), ActionSamples.game_of(player), player)
	assert_false(result.is_success)
	assert_true(player.history_entries.is_empty())


func test_failed_execute_does_not_append_a_history_entry() -> void:
	var player := _scenario()
	var result := ActionExecutor.new().execute(_FailingExecuteAction.new(), ActionSamples.game_of(player), player)
	assert_false(result.is_success)
	assert_true(player.history_entries.is_empty())


func test_105_successful_actions_cap_history_at_100_fifo() -> void:
	var player := Player.new("Test", "test", 0, 0, null, DomainSamples.buildings({HQ: 0}))
	var game := ActionSamples.game_of(player)
	var action := UpgradeBuildingAction.new(HQ)
	for i: int in 105:
		for type: ResourceType.Value in ResourceType.Value.values():
			player.resources[type].amount = 1000
		player.buildings[HQ].level = 0
		player.worksite.clear()
		game.turn = i + 1
		assert_true(ActionExecutor.new().execute(action, game, player).is_success)
	assert_eq(player.history_entries.size(), 100)
	assert_eq(player.history_entries[0].turn, 6)
	assert_eq(player.history_entries[99].turn, 105)
