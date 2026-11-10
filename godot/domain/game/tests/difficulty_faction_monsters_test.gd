extends TestCase
## test/domain/game/difficulty_faction_monsters_test.dart: the monsters
## spare the factions. 'a raid on a faction is weaker than the same raid on
## the human' and 'a kraken wave on a faction kernel is weaker too' go with
## the raid and volcano modules.


func test_monsters_spend_three_quarters_of_their_strength_on_a_faction() -> void:
	assert_eq(Difficulty.monster_percent_for(Difficulty.Value.NORMAL, false), 94)
	assert_eq(Difficulty.monster_percent_for(Difficulty.Value.NORMAL, true), 70)
	assert_eq(Difficulty.monster_percent_for(Difficulty.Value.EASY, true), 64)
	assert_eq(Difficulty.monster_percent_for(Difficulty.Value.HARD, true), 76)
