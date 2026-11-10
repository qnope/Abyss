extends TestCase
## test/domain/action/collect_treasure_action_wreck_test.dart: searching the
## wreck of a random event.

const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const PEARL := ResourceType.Value.PEARL


## Sinks a wreck at the end of turn 12 and lets the player see it.
func _sink_in_sight(game: Game, player: Player) -> GridPosition:
	WreckEffect.new().on_draw(game, player, 12, DartRandom.new(4))
	var at := player.event_state.wreck_position
	player.add_revealed_cell(1, at)
	return at


func _collect(game: Game, player: Player, at: GridPosition) -> CollectTreasureResult:
	return ActionExecutor.new().execute(CollectTreasureAction.new(at.x, at.y), game, player)


func test_a_scout_explores_the_wreck_then_searching_it_gives_its_loot() -> void:
	var player := EventSamples.wreck_player()
	var game := EventSamples.wreck_game(player, null, 13)
	WreckEffect.new().on_draw(game, player, 12, DartRandom.new(4))
	var at := player.event_state.wreck_position
	assert_true(ActionExecutor.new().execute(ExploreAction.new(at.x, at.y), game, player).is_success)
	ExplorationResolver.resolve(game)
	var noise := player.raid_state.noise

	var result := _collect(game, player, at)

	assert_true(result.is_success)
	assert_eq(result.deltas, {CORAL: EventRules.WRECK_CORAL, ORE: EventRules.WRECK_ORE, PEARL: EventRules.WRECK_PEARLS})
	assert_eq(player.raid_state.noise, noise + EventRules.WRECK_NOISE)
	assert_eq(game.current_map().cell_at(at.x, at.y).collected_by, player.id)
	assert_null(player.event_state.wreck_position)
	# Kept until the end of the turn, to tell the search from a sinking.
	assert_true(player.event_state.wreck_searched())
	assert_eq(player.event_state.wreck_until_turn, 12 + EventRules.WRECK_TURNS)
	var entries := player.history_entries.filter(func(e: HistoryEntry) -> bool: return e is CollectEntry)
	assert_eq(entries.size(), 1)
	var entry: CollectEntry = entries[0]
	assert_eq(entry.gains, result.deltas)


func test_the_wreck_raiders_bonus_lifts_the_loot_of_a_wreck() -> void:
	var player := EventSamples.wreck_player()
	var options: Array[TechOption.Value] = [TechOption.Value.A, TechOption.Value.A]
	player.tech_branches.merge(
		TechHelpers.tech_branches_with([TechHelpers.researched_branch(TechBranch.Value.EXPLORER, 4, options)]), true
	)
	var game := EventSamples.wreck_game(player, null, 13)
	var result := _collect(game, player, _sink_in_sight(game, player))
	assert_eq(result.deltas[CORAL], DartMath.trunc_div(EventRules.WRECK_CORAL * 3, 2))
	assert_eq(result.deltas[ORE], DartMath.trunc_div(EventRules.WRECK_ORE * 3, 2))
	assert_eq(result.deltas[PEARL], DartMath.trunc_div(EventRules.WRECK_PEARLS * 3, 2))


func test_the_loot_of_a_wreck_stops_at_the_storage_cap() -> void:
	var player := EventSamples.wreck_player()
	var coral: GameResource = player.resources[CORAL]
	coral.amount = coral.max_storage - 10
	var game := EventSamples.wreck_game(player, null, 13)
	var result := _collect(game, player, _sink_in_sight(game, player))
	assert_eq(result.deltas[CORAL], 10)
	assert_eq(coral.amount, coral.max_storage)


func test_searching_ruins_still_makes_no_noise() -> void:
	var game := ActionSamples.collect_game(CellContentType.Value.RUINS)
	ActionExecutor.new().execute(CollectTreasureAction.new(1, 1), game, game.human_player())
	assert_eq(game.human_player().raid_state.noise, 0)


func test_a_wreck_can_be_searched_through_the_end_of_turn_17_not_after() -> void:
	var player := EventSamples.wreck_player()
	var game := EventSamples.wreck_game(player, null, 17)
	var at := _sink_in_sight(game, player)
	EventResolver.resolve(game, player, 16, DartRandom.new(1))
	assert_true(_collect(game, player, at).is_success)

	var late := EventSamples.wreck_player()
	var late_game := EventSamples.wreck_game(late, null, 17)
	var lost := _sink_in_sight(late_game, late)
	EventResolver.resolve(late_game, late, 17, DartRandom.new(1))
	late_game.turn = 18
	var result := _collect(late_game, late, lost)
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.NOTHING_TO_COLLECT)


func test_a_searched_wreck_stays_searched_once_its_time_is_over() -> void:
	var player := EventSamples.wreck_player()
	var game := EventSamples.wreck_game(player, null, 14)
	var at := _sink_in_sight(game, player)
	_collect(game, player, at)
	EventResolver.resolve(game, player, 17, DartRandom.new(1))
	var cell := game.current_map().cell_at(at.x, at.y)
	assert_eq(cell.content, CellContentType.Value.WRECK)
	assert_eq(cell.collected_by, player.id)
