extends TestCase
## test/domain/action/fight_monster_action_military_integration_test.dart:
## the same fight, with and without the military research, on one seed.

## Seed 7 picked for deterministic reproducibility.
const SEED := 7


func _run_fight(level: int) -> FightMonsterResult:
	var game := ActionSamples.fight_game(MonsterDifficulty.Value.HARD, 4, {UnitType.Value.HARPOONIST: 6}, level)
	var action := FightMonsterAction.new(1, 1, 1, {UnitType.Value.HARPOONIST: 6}, DartRandom.new(SEED))
	return action.execute(game, game.human_player())


func _total_damage_on_monsters(r: FightMonsterResult) -> int:
	var total := 0
	for t: FightTurnSummary in r.fight.turn_summaries:
		total += t.damage_dealt_by_player
	return total


func test_fight_monster_action_military_integration_military_level_3_deals_more_damage_than_level_0() -> void:
	assert_true(_total_damage_on_monsters(_run_fight(3)) > _total_damage_on_monsters(_run_fight(0)))


func test_fight_monster_action_military_integration_military_level_3_produces_a_victory_at_least_as_often() -> void:
	var r0 := _run_fight(0)
	var r3 := _run_fight(3)
	assert_false(r0.victory and not r3.victory)


func test_fight_monster_action_military_integration_bonus_also_visible_on_initial_player_combatants_atk() -> void:
	assert_true(_run_fight(3).fight.initial_player_combatants[0].atk > _run_fight(0).fight.initial_player_combatants[0].atk)
