extends TestCase
## test/domain/action/make_history_entry_test.dart, the groups
## 'Action.makeHistoryEntry base default', 'UpgradeBuildingAction
## .makeHistoryEntry' and 'RecruitUnitAction.makeHistoryEntry'; the others
## are make_history_entry_<group>_test.gd.


class _NoEntryAction extends Action:
	func type() -> ActionType.Value:
		return ActionType.Value.UPGRADE_BUILDING

	func description() -> String:
		return "noop"

	func validate(_game: Game, _player: Player) -> ActionResult:
		return ActionResult.success()

	func execute(_game: Game, _player: Player) -> ActionResult:
		return ActionResult.success()


func _stocked(levels: Dictionary[BuildingType.Value, int]) -> Player:
	return ActionSamples.stocked(ActionSamples.amounts(500, 500, 500, 500, 50), levels)


func test_action_make_history_entry_base_default_returns_null_on_a_subclass_that_does_not_override() -> void:
	var player := Player.new("Test", "test")
	var game := ActionSamples.game_of(player)
	var action := _NoEntryAction.new()
	var result := action.execute(game, player)
	assert_null(action.make_history_entry(game, player, result, 1))


func test_upgrade_building_action_make_history_entry_returns_building_entry_with_post_execute_level() -> void:
	var player := ActionSamples.stocked(
		ActionSamples.amounts(200, 200, 200, 200, 20), {BuildingType.Value.HEADQUARTERS: 0}
	)
	var game := ActionSamples.game_of(player)
	var action := UpgradeBuildingAction.new(BuildingType.Value.HEADQUARTERS)
	var result := action.execute(game, player)
	assert_true(result.is_success)
	var building: BuildingEntry = action.make_history_entry(game, player, result, 3)
	assert_eq([building.turn, building.category], [3, HistoryEntryCategory.Value.BUILDING])
	assert_eq([building.building_type, building.new_level], [BuildingType.Value.HEADQUARTERS, 1])


func test_recruit_unit_action_make_history_entry_returns_recruit_entry_with_unit_type_and_quantity() -> void:
	var player := _stocked({BuildingType.Value.BARRACKS: 1})
	var game := ActionSamples.game_of(player)
	var action := RecruitUnitAction.new(UnitType.Value.SCOUT, 4)
	var result := action.execute(game, player)
	assert_true(result.is_success)
	var recruit: RecruitEntry = action.make_history_entry(game, player, result, 9)
	assert_eq([recruit.turn, recruit.category], [9, HistoryEntryCategory.Value.RECRUIT])
	assert_eq([recruit.unit_type, recruit.quantity], [UnitType.Value.SCOUT, 4])
