extends TestCase
## test/domain/game/difficulty_faction_test.dart: the production of a
## faction moves against the human one.

const CORAL := ResourceType.Value.CORAL
const ENERGY := ResourceType.Value.ENERGY
const PEARL := ResourceType.Value.PEARL


func test_factions_produce_90_100_and_110_percent_by_difficulty() -> void:
	assert_eq(Difficulty.faction_percent(Difficulty.Value.EASY), 90)
	assert_eq(Difficulty.faction_percent(Difficulty.Value.NORMAL), 100)
	assert_eq(Difficulty.faction_percent(Difficulty.Value.HARD), 110)


## Algae the default base earns in one end of turn.
static func _algae_gained(difficulty: Difficulty.Value, faction: bool) -> int:
	var player := Player.new("p")
	player.buildings[BuildingType.Value.ALGAE_FARM] = Building.new(BuildingType.Value.ALGAE_FARM, 5)
	var before := player.resources[ResourceType.Value.ALGAE].amount
	PlayerTurnResolver.resolve(player, 1, {}, difficulty, faction)
	return player.resources[ResourceType.Value.ALGAE].amount - before


func test_the_production_of_a_faction_moves_against_the_human_one() -> void:
	var normal := _algae_gained(Difficulty.Value.NORMAL, true)
	assert_true(normal > 0)
	assert_true(_algae_gained(Difficulty.Value.EASY, true) < _algae_gained(Difficulty.Value.EASY, false))
	assert_true(_algae_gained(Difficulty.Value.HARD, true) > _algae_gained(Difficulty.Value.HARD, false))
	assert_true(_algae_gained(Difficulty.Value.EASY, true) < normal)
	assert_true(_algae_gained(Difficulty.Value.HARD, true) > normal)


func test_the_human_production_keeps_its_own_levers() -> void:
	var easy := _algae_gained(Difficulty.Value.EASY, false)
	var normal := _algae_gained(Difficulty.Value.NORMAL, false)
	var hard := _algae_gained(Difficulty.Value.HARD, false)

	assert_true(easy > normal)
	assert_true(hard < normal)
	assert_eq(normal, _algae_gained(Difficulty.Value.NORMAL, true))


func test_energy_and_pearls_are_not_scaled_for_a_faction_either() -> void:
	var production := Difficulty.scale_production(
		Difficulty.Value.HARD, {ENERGY: 100, PEARL: 100, CORAL: 100}, true
	)
	assert_eq(production[ENERGY], 100)
	assert_eq(production[PEARL], 100)
	assert_eq(production[CORAL], 110)
