extends TestCase
## test/domain/action/collect_treasure_action_execute_test.dart: what a
## treasure and ruins give.

const M := CollectTreasureAction.REWARD_MULTIPLIER
const ALGAE := ResourceType.Value.ALGAE
const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const PEARL := ResourceType.Value.PEARL
const BONUS := CellContentType.Value.RESOURCE_BONUS
const RUINS := CellContentType.Value.RUINS


func _collect(content: CellContentType.Value, seed_: int) -> CollectTreasureResult:
	var game := ActionSamples.collect_game(content)
	return CollectTreasureAction.new(1, 1, 1, DartRandom.new(seed_)).execute(game, game.human_player())


func _within(value: int, low: int, high: int, seed_: int) -> void:
	assert_true(value >= low and value <= high, "seed=%d: %d" % [seed_, value])


func test_collect_treasure_action_execute_resource_bonus_adds_algae_coral_and_ore() -> void:
	var result := _collect(BONUS, 42)
	assert_true(result.is_success)
	# Random(42): nextInt(51)=7, nextInt(21)=15, nextInt(21)=12
	assert_eq(result.deltas, {ALGAE: (50 + 7) * M, CORAL: (30 + 15) * M, ORE: (30 + 12) * M})
	assert_false(result.deltas.has(PEARL))


func test_collect_treasure_action_execute_ruins_adds_algae_coral_ore_and_pearl() -> void:
	var result := _collect(RUINS, 42)
	assert_true(result.is_success)
	# Random(42): nextInt(101)=5, nextInt(26)=8, nextInt(26)=6, nextInt(3)=1
	assert_eq(result.deltas, {ALGAE: 5 * M, CORAL: 8 * M, ORE: 6 * M, PEARL: 1 * M})


func test_collect_treasure_action_execute_resource_bonus_amounts_stay_within_configured_ranges() -> void:
	for seed_: int in 50:
		var deltas := _collect(BONUS, seed_).deltas
		_within(deltas[ALGAE], 50 * M, 100 * M, seed_)
		_within(deltas[CORAL], 30 * M, 50 * M, seed_)
		_within(deltas[ORE], 30 * M, 50 * M, seed_)


func test_collect_treasure_action_execute_ruins_amounts_stay_within_new_ranges() -> void:
	for seed_: int in 50:
		var deltas := _collect(RUINS, seed_).deltas
		_within(deltas[ALGAE], 0, 100 * M, seed_)
		_within(deltas[CORAL], 0, 25 * M, seed_)
		_within(deltas[ORE], 0, 25 * M, seed_)
		_within(deltas[PEARL], 0, 2 * M, seed_)


func test_collect_treasure_action_execute_stamps_collected_by_with_calling_player_id_on_success() -> void:
	var game := ActionSamples.collect_game(RUINS)
	CollectTreasureAction.new(1, 1, 1, DartRandom.new(42)).execute(game, game.human_player())
	assert_eq(game.levels[1].cell_at(1, 1).collected_by, game.human_player().id)
	assert_true(game.levels[1].cell_at(1, 1).is_collected())


func test_collect_treasure_action_execute_collecting_already_collected_cell_fails() -> void:
	var game := ActionSamples.collect_game(BONUS)
	CollectTreasureAction.new(1, 1).execute(game, game.human_player())
	var result := CollectTreasureAction.new(1, 1).execute(game, game.human_player())
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.ALREADY_COLLECTED)


## Not in the Dart file: the research's loot percent counts before the cap,
## and the description says where.
func test_the_loot_percent_counts_and_the_description_says_where() -> void:
	var game := ActionSamples.collect_game(BONUS)
	var player := game.human_player()
	var options: Array[TechOption.Value] = [TechOption.Value.A, TechOption.Value.A]
	player.tech_branches = TechHelpers.tech_branches_with([TechHelpers.researched_branch(TechBranch.Value.EXPLORER, 4, options)])
	var percent := TechEffects.of(player).loot_percent()
	var result: CollectTreasureResult = CollectTreasureAction.new(1, 1, 1, DartRandom.new(42)).execute(game, player)
	assert_eq(result.deltas[ALGAE], DartMath.trunc_div((50 + 7) * M * percent, 100))
	var action := CollectTreasureAction.new(1, 2)
	assert_eq([action.type(), action.description()], [ActionType.Value.COLLECT_TREASURE, "Collecter (1, 2)"])
