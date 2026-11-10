extends TestCase
## test/domain/action/fight_monster_action_victory_test.dart: a lair
## defeated.

const HARPOONIST := UnitType.Value.HARPOONIST


func _amounts(player: Player) -> Dictionary[ResourceType.Value, int]:
	var amounts: Dictionary[ResourceType.Value, int] = {}
	for type: ResourceType.Value in player.resources:
		amounts[type] = player.resources[type].amount
	return amounts


func test_fight_monster_action_victory_stomps_a_single_easy_monster_deterministically() -> void:
	var game := ActionSamples.fight_game(MonsterDifficulty.Value.EASY, 1, {HARPOONIST: 20})
	var player := game.human_player()
	var before := _amounts(player)
	var action := FightMonsterAction.new(1, 1, 1, {HARPOONIST: 20}, DartRandom.new(0))
	var result := action.execute(game, player)
	assert_true(result is FightMonsterResult)
	var fight: FightMonsterResult = result
	assert_true(fight.victory)
	var cell := game.levels[1].cell_at(1, 1)
	assert_true(cell.is_collected())
	assert_eq(cell.collected_by, player.id)
	for type: ResourceType.Value in fight.loot:
		assert_eq(player.resources[type].amount - before[type], fight.loot[type], "delta of %d" % type)
	assert_true(fight.wounded.is_empty())
	assert_true(fight.dead.is_empty())
	assert_eq(fight.survivors_intact, {HARPOONIST: 20})
	assert_eq(fight.sent, {HARPOONIST: 20})


func test_fight_monster_action_victory_loot_matches_a_loot_calculator_invocation_with_equivalent_seed() -> void:
	var loot := LootCalculator.new(DartRandom.new(7)).compute(MonsterDifficulty.Value.EASY)
	for type: ResourceType.Value in [ResourceType.Value.ALGAE, ResourceType.Value.CORAL, ResourceType.Value.ORE, ResourceType.Value.PEARL]:
		assert_has(loot.keys(), type)
	assert_eq(loot[ResourceType.Value.PEARL], 0)

