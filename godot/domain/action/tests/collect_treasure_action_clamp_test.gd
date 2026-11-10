extends TestCase
## test/domain/action/collect_treasure_action_clamp_test.dart: a search
## stops at the storage cap.


func test_collect_treasure_action_execute_clamping_resource_bonus_delta_is_clamped_at_max_storage() -> void:
	var game := ActionSamples.collect_game(CellContentType.Value.RESOURCE_BONUS)
	var player := game.human_player()
	player.resources[ResourceType.Value.ALGAE].amount = 4990
	var result: CollectTreasureResult = CollectTreasureAction.new(1, 1).execute(game, player)
	assert_true(result.deltas[ResourceType.Value.ALGAE] <= 10)
	assert_eq(result.deltas[ResourceType.Value.ALGAE], 5000 - 4990)
	assert_eq(player.resources[ResourceType.Value.ALGAE].amount, 5000)


func test_collect_treasure_action_execute_clamping_ruins_delta_is_clamped_at_max_storage_when_resource_full() -> void:
	var game := ActionSamples.collect_game(CellContentType.Value.RUINS)
	var player := game.human_player()
	for resource: GameResource in player.resources.values():
		resource.amount = resource.max_storage
	var result: CollectTreasureResult = CollectTreasureAction.new(1, 1, 1, DartRandom.new(42)).execute(game, player)
	for type: ResourceType.Value in [ResourceType.Value.ALGAE, ResourceType.Value.CORAL, ResourceType.Value.ORE, ResourceType.Value.PEARL]:
		assert_eq(result.deltas[type], 0)
