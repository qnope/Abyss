extends TestCase
## test/domain/game/difficulty_faction_test.dart: the production of a
## faction moves against the human one. 'the production of a faction moves
## against the human one' and 'the human production keeps its own levers'
## resolve the turn of a Player and go with the game and turn modules.

const CORAL := ResourceType.Value.CORAL
const ENERGY := ResourceType.Value.ENERGY
const PEARL := ResourceType.Value.PEARL


func test_factions_produce_90_100_and_110_percent_by_difficulty() -> void:
	assert_eq(Difficulty.faction_percent(Difficulty.Value.EASY), 90)
	assert_eq(Difficulty.faction_percent(Difficulty.Value.NORMAL), 100)
	assert_eq(Difficulty.faction_percent(Difficulty.Value.HARD), 110)


func test_energy_and_pearls_are_not_scaled_for_a_faction_either() -> void:
	var production := Difficulty.scale_production(
		Difficulty.Value.HARD, {ENERGY: 100, PEARL: 100, CORAL: 100}, true
	)
	assert_eq(production[ENERGY], 100)
	assert_eq(production[PEARL], 100)
	assert_eq(production[CORAL], 110)
