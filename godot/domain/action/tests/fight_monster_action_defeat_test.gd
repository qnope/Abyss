extends TestCase
## test/domain/action/fight_monster_action_defeat_test.dart: a fight lost.

const SCOUT := UnitType.Value.SCOUT


func _amounts(player: Player) -> Dictionary[ResourceType.Value, int]:
	var amounts: Dictionary[ResourceType.Value, int] = {}
	for type: ResourceType.Value in player.resources:
		amounts[type] = player.resources[type].amount
	return amounts


func test_fight_monster_action_defeat_a_single_scout_loses_against_a_level_3_lair() -> void:
	var game := ActionSamples.fight_game(MonsterDifficulty.Value.HARD, 5, {SCOUT: 1})
	var player := game.human_player()
	var before := _amounts(player)
	var action := FightMonsterAction.new(1, 1, 1, {SCOUT: 1}, DartRandom.new(1))
	var result: FightMonsterResult = action.execute(game, player)
	assert_false(result.victory)
	var cell := game.levels[1].cell_at(1, 1)
	assert_false(cell.is_collected())
	assert_null(cell.collected_by)
	assert_eq(_amounts(player), before)
	assert_eq(result.wounded.get(SCOUT, 0) + result.dead.get(SCOUT, 0), 1)
	assert_eq(result.sent[SCOUT], 1)
	assert_eq(result.survivors_intact.get(SCOUT, 0), 0)
