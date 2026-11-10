extends TestCase
## test/domain/action/collect_treasure_action_ranges_test.dart: the bounds
## of ruins are both reached.


func test_collect_treasure_action_ranges_ruins_min_and_max_are_reachable() -> void:
	var m := CollectTreasureAction.REWARD_MULTIPLIER
	var maxes: Dictionary[ResourceType.Value, int] = {}
	var mins: Dictionary[ResourceType.Value, int] = {}
	for seed_: int in 200:
		var game := ActionSamples.collect_game(CellContentType.Value.RUINS)
		var action := CollectTreasureAction.new(1, 1, 1, DartRandom.new(seed_))
		var result: CollectTreasureResult = action.execute(game, game.human_player())
		for type: ResourceType.Value in result.deltas:
			var value: int = result.deltas[type]
			var high: int = maxes.get(type, value)
			var low: int = mins.get(type, value)
			maxes[type] = maxi(high, value)
			mins[type] = mini(low, value)
	assert_eq(maxes, {
		ResourceType.Value.ALGAE: 100 * m, ResourceType.Value.CORAL: 25 * m,
		ResourceType.Value.ORE: 25 * m, ResourceType.Value.PEARL: 2 * m,
	})
	assert_eq(mins.values(), [0, 0, 0, 0])
