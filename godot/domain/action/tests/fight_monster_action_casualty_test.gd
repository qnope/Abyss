extends TestCase
## test/domain/action/fight_monster_action_casualty_test.dart: only the dead
## leave the stock.

const HARPOONIST := UnitType.Value.HARPOONIST


func _fight(game: Game, seed_: int) -> FightMonsterResult:
	return FightMonsterAction.new(1, 1, 1, {HARPOONIST: 6}, DartRandom.new(seed_)).execute(game, game.human_player())


func test_fight_monster_action_casualty_accounting_survivors_and_wounded_are_restored_final_stock_initial_dead() -> void:
	var game := ActionSamples.fight_game(MonsterDifficulty.Value.MEDIUM, 4, {HARPOONIST: 6})
	var initial_stock := game.human_player().units_on_level(1)[HARPOONIST].count
	var result := _fight(game, 3)
	assert_eq(result.sent, {HARPOONIST: 6})
	var survivors: int = result.survivors_intact.get(HARPOONIST, 0)
	var wounded: int = result.wounded.get(HARPOONIST, 0)
	var dead: int = result.dead.get(HARPOONIST, 0)
	assert_eq(survivors + wounded + dead, result.sent[HARPOONIST])
	assert_eq(game.human_player().units_on_level(1)[HARPOONIST].count, initial_stock - dead)


func test_fight_monster_action_casualty_accounting_seeded_run_is_reproducible() -> void:
	var r1 := _fight(ActionSamples.fight_game(MonsterDifficulty.Value.MEDIUM, 4, {HARPOONIST: 6}), 42)
	var r2 := _fight(ActionSamples.fight_game(MonsterDifficulty.Value.MEDIUM, 4, {HARPOONIST: 6}), 42)
	assert_eq(r1.victory, r2.victory)
	assert_eq(r1.wounded, r2.wounded)
	assert_eq(r1.dead, r2.dead)
	assert_eq(r1.survivors_intact, r2.survivors_intact)
	assert_eq(r1.loot, r2.loot)
