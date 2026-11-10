extends TestCase
## test/domain/game/difficulty_world_relief_test.dart: the monsters ease on
## the human as the world grows with the factions. 'a raid on the human is
## smaller in a world of ten factions' and 'a kraken wave on the human
## kernel is lighter too' go with the raid and volcano modules.

const NORMAL := Difficulty.Value.NORMAL


func test_a_game_without_faction_keeps_the_monsters_it_always_had() -> void:
	assert_eq(Difficulty.world_relief_percent(0), 100)
	assert_eq(Difficulty.monster_percent_for(NORMAL, false), 94)


func test_the_more_factions_the_bigger_the_world_and_the_lighter_the_raids() -> void:
	var reliefs: Array[int] = []
	for factions: int in [0, 1, 3, 5, 10]:
		reliefs.append(Difficulty.world_relief_percent(factions))
	assert_eq(reliefs, [100, 97, 92, 87, 75])


func test_the_relief_eases_the_human_only_never_a_faction() -> void:
	assert_eq(Difficulty.monster_percent_for(NORMAL, false, 3), DartMath.trunc_div(94 * 92, 100))
	assert_eq(
		Difficulty.monster_percent_for(NORMAL, true, 3),
		Difficulty.monster_percent_for(NORMAL, true)
	)
