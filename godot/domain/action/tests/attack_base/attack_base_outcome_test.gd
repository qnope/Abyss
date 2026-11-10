extends TestCase
## test/domain/action/attack_base/attack_base_outcome_test.dart: what a won
## or lost attack does to the rampart, the headquarters and the stocks.

const HQ := BuildingType.Value.HEADQUARTERS
const CITADEL := BuildingType.Value.CORAL_CITADEL
const CORAL := ResourceType.Value.CORAL
const PEARL := ResourceType.Value.PEARL


func _win(game: Game, army: Dictionary[UnitType.Value, int] = AssaultSamples.HORDE) -> AttackBaseResult:
	AssaultSamples.station(game.human_player(), army)
	var result: AttackBaseResult = AssaultSamples.strike(game, army).execute(game, game.human_player())
	return result


func _level(game: Game, type: BuildingType.Value) -> int:
	return AssaultSamples.rival_of(game).buildings[type].level


func test_a_won_attack_lowers_the_rampart_by_two_levels() -> void:
	var game := AssaultSamples.assault_game()
	AssaultSamples.set_level(AssaultSamples.rival_of(game), CITADEL, 4)
	var result := _win(game)
	assert_true(result.victory)
	assert_eq(_level(game, CITADEL), 2)
	assert_eq(_level(game, HQ), 5)
	assert_eq(result.damage.rampart_before, 4)
	assert_eq(result.damage.rampart_after, 2)


func test_the_rampart_stops_at_level_0_and_spares_the_headquarters() -> void:
	var game := AssaultSamples.assault_game()
	AssaultSamples.set_level(AssaultSamples.rival_of(game), CITADEL, 1)
	_win(game)
	assert_eq(_level(game, CITADEL), 0)
	assert_eq(_level(game, HQ), 5)


func test_without_a_rampart_the_headquarters_falls_by_one_level() -> void:
	var game := AssaultSamples.assault_game()
	var result := _win(game)
	assert_eq(_level(game, HQ), 4)
	assert_eq(result.damage.headquarters_before, 5)
	assert_eq(result.damage.headquarters_after, 4)


func test_the_headquarters_never_falls_under_level_1() -> void:
	var game := AssaultSamples.assault_game()
	AssaultSamples.set_level(AssaultSamples.rival_of(game), HQ, 1)
	_win(game)
	assert_eq(_level(game, HQ), 1)


func test_a_won_attack_pillages_30_percent_of_the_stocks_pearls_aside() -> void:
	var game := AssaultSamples.assault_game()
	var rival := AssaultSamples.rival_of(game)
	var human := game.human_player()
	rival.resources[CORAL].amount = 1000
	rival.resources[PEARL].amount = 50
	human.resources[CORAL].amount = 0
	var result := _win(game)
	assert_eq(result.damage.pillaged[CORAL], 300)
	assert_eq(rival.resources[CORAL].amount, 700)
	assert_eq(human.resources[CORAL].amount, 300)
	assert_false(result.damage.pillaged.has(PEARL))
	assert_eq(rival.resources[PEARL].amount, 50)
	assert_eq(human.resources[PEARL].amount, 5)


func test_the_loot_stops_at_the_storage_of_the_attacker() -> void:
	var game := AssaultSamples.assault_game()
	var rival := AssaultSamples.rival_of(game)
	var human := game.human_player()
	rival.resources[CORAL].amount = 1000
	human.resources[CORAL] = GameResource.new(CORAL, 4900, 5000)
	var result := _win(game)
	assert_eq(human.resources[CORAL].amount, 5000)
	assert_eq(result.damage.loot[CORAL], 100)
	assert_eq(rival.resources[CORAL].amount, 700)


func test_a_lost_attack_takes_and_breaks_nothing_and_costs_units() -> void:
	var game := AssaultSamples.assault_game()
	var rival := AssaultSamples.rival_of(game)
	var human := game.human_player()
	AssaultSamples.station(rival, AssaultSamples.WALL)
	AssaultSamples.set_level(rival, CITADEL, 4)
	var coral := rival.resources[CORAL].amount
	var mine := human.resources[CORAL].amount
	var result := _win(game, {UnitType.Value.SCOUT: 3})
	assert_false(result.victory)
	assert_eq(_level(game, CITADEL), 4)
	assert_eq(_level(game, HQ), 5)
	assert_true(result.damage.pillaged.is_empty())
	assert_eq(rival.resources[CORAL].amount, coral)
	assert_eq(human.resources[CORAL].amount, mine)
	var survivors := AssaultSamples.standing(human, UnitType.Value.SCOUT)
	assert_true(survivors <= 3)
	var dead: int = result.dead.get(UnitType.Value.SCOUT, 0)
	assert_true(survivors + dead - 3 <= 0)
