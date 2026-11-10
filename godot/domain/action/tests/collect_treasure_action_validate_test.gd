extends TestCase
## test/domain/action/collect_treasure_action_validate_test.dart: which
## cells may be searched.


func _validate(game: Game) -> ActionResult:
	return CollectTreasureAction.new(1, 1).validate(game, game.human_player())


func _reason_on(content: CellContentType.Value, collected_by: Variant = null) -> Variant:
	return _validate(ActionSamples.collect_game(content, null, collected_by)).reason


func test_collect_treasure_action_validate_fails_when_map_is_null() -> void:
	var player := ActionSamples.collect_player()
	var result := _validate(ActionSamples.game_of(player))
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.MAP_NOT_GENERATED)


func test_collect_treasure_action_validate_fails_when_cell_is_not_revealed() -> void:
	var levels := ActionSamples.collect_game().levels
	var player := Player.new("Test", "test", 2, 2)
	var game := Game.new(player.id, {player.id: player}, 1, levels)
	var result := _validate(game)
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.CELL_NOT_REVEALED)


func test_collect_treasure_action_validate_fails_when_cell_is_already_collected_by_someone_else() -> void:
	assert_eq(_reason_on(CellContentType.Value.RESOURCE_BONUS, "other-player"), ActionFailure.Value.ALREADY_COLLECTED)


func test_collect_treasure_action_validate_fails_when_cell_is_already_collected_by_caller_double_collect() -> void:
	assert_eq(_reason_on(CellContentType.Value.RESOURCE_BONUS, "test-uuid"), ActionFailure.Value.ALREADY_COLLECTED)


func test_collect_treasure_action_validate_fails_when_cell_is_empty() -> void:
	assert_eq(_reason_on(CellContentType.Value.EMPTY), ActionFailure.Value.NOTHING_TO_COLLECT)


func test_collect_treasure_action_validate_fails_when_cell_is_monster_lair() -> void:
	assert_eq(_reason_on(CellContentType.Value.MONSTER_LAIR), ActionFailure.Value.NOTHING_TO_COLLECT)


func test_collect_treasure_action_validate_succeeds_for_resource_bonus() -> void:
	assert_true(_validate(ActionSamples.collect_game(CellContentType.Value.RESOURCE_BONUS)).is_success)


func test_collect_treasure_action_validate_succeeds_for_ruins() -> void:
	assert_true(_validate(ActionSamples.collect_game(CellContentType.Value.RUINS)).is_success)
