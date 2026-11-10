extends TestCase
## test/domain/action/fight_monster_action_integration_test.dart: a fight
## from start to end.

const HARPOONIST := UnitType.Value.HARPOONIST
const SABOTEUR := UnitType.Value.SABOTEUR


func _game(difficulty: MonsterDifficulty.Value, unit_count: int, stock: Dictionary[UnitType.Value, int]) -> Game:
	var game := ActionSamples.fight_game(difficulty, unit_count, stock)
	game.human_player().add_revealed_cell(1, GridPosition.new(1, 1))
	return game


func _amounts(player: Player) -> Dictionary[ResourceType.Value, int]:
	var amounts: Dictionary[ResourceType.Value, int] = {}
	for type: ResourceType.Value in player.resources:
		amounts[type] = player.resources[type].amount
	return amounts


func test_fight_monster_action_integration_victory_full_flow_cell_collected_loot_applied_stock_preserved() -> void:
	var game := _game(MonsterDifficulty.Value.EASY, 4, {HARPOONIST: 20})
	var player := game.human_player()
	var before := _amounts(player)
	var initial := player.units_on_level(1)[HARPOONIST].count
	var result: FightMonsterResult = FightMonsterAction.new(1, 1, 1, {HARPOONIST: 5}, DartRandom.new(0)).execute(game, player)
	assert_true(result.victory)
	var cell := game.levels[1].cell_at(1, 1)
	assert_eq([cell.is_collected(), cell.collected_by], [true, player.id])
	assert_not_null(cell.lair, "Collected lair should keep its composition")
	for type: ResourceType.Value in result.loot:
		assert_eq(player.resources[type].amount - before[type], result.loot[type])
	assert_eq(player.units_on_level(1)[HARPOONIST].count, initial - result.dead.get(HARPOONIST, 0))


func test_fight_monster_action_integration_defeat_full_flow_cell_untouched_resources_intact_unit_consumed() -> void:
	var game := _game(MonsterDifficulty.Value.HARD, 150, {SABOTEUR: 1})
	var player := game.human_player()
	var before := _amounts(player)
	var result: FightMonsterResult = FightMonsterAction.new(1, 1, 1, {SABOTEUR: 1}, DartRandom.new(1)).execute(game, player)
	assert_false(result.victory)
	var cell := game.levels[1].cell_at(1, 1)
	assert_eq([cell.is_collected(), cell.collected_by], [false, null])
	assert_eq(_amounts(player), before)
	assert_eq(player.units_on_level(1)[SABOTEUR].count, 1 - result.dead.get(SABOTEUR, 0))
	assert_eq(result.sent[SABOTEUR], 1)


func test_fight_monster_action_integration_casualty_restoration_survivors_and_wounded_return_to_stock() -> void:
	var game := _game(MonsterDifficulty.Value.MEDIUM, 6, {HARPOONIST: 8})
	var player := game.human_player()
	var initial := player.units_on_level(1)[HARPOONIST].count
	var result: FightMonsterResult = FightMonsterAction.new(1, 1, 1, {HARPOONIST: 8}, DartRandom.new(0)).execute(game, player)
	var sent: int = result.sent.get(HARPOONIST, 0)
	var dead: int = result.dead.get(HARPOONIST, 0)
	assert_true(result.victory)
	assert_eq(sent, 8)
	assert_eq(result.survivors_intact.get(HARPOONIST, 0) + result.wounded.get(HARPOONIST, 0) + dead, sent)
	var total_wounded := 0
	for count: int in result.wounded.values():
		total_wounded += count
	assert_true(total_wounded > 0, "Balanced fight should produce at least one wounded unit")
	assert_eq(player.units_on_level(1)[HARPOONIST].count, initial - dead)
