extends TestCase
## test/domain/action/fight_monster_action_level_test.dart: fighting on the
## levels below with the units there.

const HARPOONIST := UnitType.Value.HARPOONIST


## The game of the fight scenario with `stock` on level 1, a second fight
## map on level 2 and `deep` harpoonists there.
func _game(stock: int, deep: int, unit_count := 1) -> Game:
	var game := ActionSamples.fight_game(MonsterDifficulty.Value.EASY, 1, {HARPOONIST: stock})
	game.levels[2] = ActionSamples.fight_map(MonsterDifficulty.Value.EASY, unit_count)
	var counts: Dictionary[UnitType.Value, int] = {}
	for type: UnitType.Value in UnitType.Value.values():
		counts[type] = deep if type == HARPOONIST else 0
	game.human_player().units_per_level[2] = DomainSamples.units(counts)
	return game


func test_fight_monster_action_level_support_validates_against_correct_level_map_and_units() -> void:
	var game := _game(5, 3)
	assert_true(FightMonsterAction.new(1, 1, 2, {HARPOONIST: 3}).validate(game, game.human_player()).is_success)


func test_fight_monster_action_level_support_fails_when_units_insufficient_on_target_level() -> void:
	var game := _game(10, 1)
	var result := FightMonsterAction.new(1, 1, 2, {HARPOONIST: 5}).validate(game, game.human_player())
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.NOT_ENOUGH_UNITS)


func test_fight_monster_action_level_support_deducts_units_from_correct_level_on_execute() -> void:
	var game := _game(10, 5)
	FightMonsterAction.new(1, 1, 2, {HARPOONIST: 3}, DartRandom.new(0)).execute(game, game.human_player())
	assert_eq(game.human_player().units_on_level(1)[HARPOONIST].count, 10)


func test_fight_monster_action_level_support_survivors_restored_to_same_level_after_fight() -> void:
	var game := _game(10, 8)
	var result := FightMonsterAction.new(1, 1, 2, {HARPOONIST: 5}, DartRandom.new(0)).execute(game, game.human_player())
	assert_true(result.is_success)
	assert_eq(game.human_player().units_on_level(1)[HARPOONIST].count, 10)


func test_fight_monster_action_level_support_fails_when_level_2_map_does_not_exist() -> void:
	var game := ActionSamples.fight_game(MonsterDifficulty.Value.EASY, 1, {HARPOONIST: 5})
	var result := FightMonsterAction.new(1, 1, 2, {HARPOONIST: 1}).validate(game, game.human_player())
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.MAP_NOT_GENERATED)
