extends TestCase
## test/domain/action/fight_monster_action_validate_test.dart: what a fight
## against a lair needs.

const HARPOONIST := UnitType.Value.HARPOONIST


func _validate(game: Game, selected: Dictionary[UnitType.Value, int]) -> ActionResult:
	return FightMonsterAction.new(1, 1, 1, selected).validate(game, game.human_player())


func test_fight_monster_action_validate_fails_when_map_is_null() -> void:
	var player := ActionSamples.fight_player({HARPOONIST: 5})
	var result := _validate(ActionSamples.game_of(player), {HARPOONIST: 1})
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.MAP_NOT_GENERATED)
	assert_true(result is FightMonsterResult)


func test_fight_monster_action_validate_fails_when_cell_is_not_a_monster_lair() -> void:
	var game := ActionSamples.fight_game(MonsterDifficulty.Value.EASY, 1, {HARPOONIST: 5}, 0, null, false, CellContentType.Value.EMPTY)
	assert_eq(_validate(game, {HARPOONIST: 1}).reason, ActionFailure.Value.NO_MONSTER_HERE)


func test_fight_monster_action_validate_fails_when_cell_is_already_collected() -> void:
	var game := ActionSamples.fight_game(MonsterDifficulty.Value.EASY, 1, {HARPOONIST: 5}, 0, "test-uuid")
	assert_eq(_validate(game, {HARPOONIST: 1}).reason, ActionFailure.Value.LAIR_ALREADY_DEFEATED)


func test_fight_monster_action_validate_fails_when_lair_data_is_missing() -> void:
	var game := ActionSamples.fight_game(MonsterDifficulty.Value.EASY, 1, {HARPOONIST: 5}, 0, null, false)
	# content defaults to monsterLair -> falls through to lair null
	assert_eq(_validate(game, {HARPOONIST: 1}).reason, ActionFailure.Value.LAIR_EMPTY)


func test_fight_monster_action_validate_fails_when_selected_count_exceeds_stock() -> void:
	var game := ActionSamples.fight_game(MonsterDifficulty.Value.EASY, 1, {HARPOONIST: 2})
	assert_eq(_validate(game, {HARPOONIST: 10}).reason, ActionFailure.Value.NOT_ENOUGH_UNITS)


func test_fight_monster_action_validate_fails_on_all_zero_selection() -> void:
	var game := ActionSamples.fight_game(MonsterDifficulty.Value.EASY, 1, {HARPOONIST: 5})
	assert_eq(_validate(game, {HARPOONIST: 0}).reason, ActionFailure.Value.NO_UNIT_SELECTED)


func test_fight_monster_action_validate_fails_on_empty_selection() -> void:
	var game := ActionSamples.fight_game(MonsterDifficulty.Value.EASY, 1, {HARPOONIST: 5})
	assert_eq(_validate(game, {}).reason, ActionFailure.Value.NO_UNIT_SELECTED)


func test_fight_monster_action_validate_succeeds_on_happy_path() -> void:
	var game := ActionSamples.fight_game(MonsterDifficulty.Value.EASY, 1, {HARPOONIST: 5})
	assert_true(_validate(game, {HARPOONIST: 2}).is_success)


## Not in the Dart file: a refused fight leaves the units and the lair.
func test_a_refused_fight_changes_nothing() -> void:
	var game := ActionSamples.fight_game(MonsterDifficulty.Value.EASY, 1, {HARPOONIST: 5})
	var player := game.human_player()
	var selected: Dictionary[UnitType.Value, int] = {HARPOONIST: 9}
	var result := FightMonsterAction.new(1, 1, 1, selected).execute(game, player)
	assert_eq([result.is_success, result.reason], [false, ActionFailure.Value.NOT_ENOUGH_UNITS])
	assert_eq(Unit.count_in(player.units_on_level(1), HARPOONIST), 5)
	assert_null(game.levels[1].cell_at(1, 1).collected_by)
