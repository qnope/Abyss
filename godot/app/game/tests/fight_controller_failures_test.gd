extends FightControllerCase
## Why a launch is refused, for each reason the fight can give
## (fight_monster_action_validate_test.dart): told in the selection page, which
## stays open, with the game left as it was.

const Failure := ActionFailure.Value


## Opens the army, picks two harpoonists, lets [param spoil] change the game
## the way it could meanwhile, and presses "launch".
func _launch_after(spoil: Callable) -> ArmySelection:
	var page := open_selection()
	page.rows[Harpoonist].set_value(2)
	spoil.call()
	press("Lancer le combat")
	return page


func _assert_refused(page: ArmySelection, reason: Failure) -> void:
	assert_true(page.failure_label.visible)
	assert_eq(page.failure_label.text, ActionFailureTexts.message(reason))
	assert_eq(current_modal(), page, "the page stays open")
	assert_false(page.is_closed())
	assert_eq(stock(Scout), 3)
	assert_eq(human.history_entries.size(), 0)
	assert_eq(repository.load_all().games.size(), 0, "nothing was saved")
	assert_no_raw_keys(page)


func test_the_map_of_the_level_is_gone() -> void:
	var page := _launch_after(func() -> void: game.levels.erase(1))
	_assert_refused(page, Failure.MAP_NOT_GENERATED)


func test_there_is_no_lair_on_the_cell_any_more() -> void:
	var page := _launch_after(func() -> void: game.levels[1].set_cell(lair_at.x, lair_at.y, MapCell.new(TerrainType.Value.PLAIN)))
	_assert_refused(page, Failure.NO_MONSTER_HERE)


func test_the_lair_was_beaten_meanwhile() -> void:
	var beaten := MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.MONSTER_LAIR,
		MonsterLair.new(MonsterDifficulty.Value.EASY, 1), "me")
	var page := _launch_after(func() -> void: game.levels[1].set_cell(lair_at.x, lair_at.y, beaten))
	_assert_refused(page, Failure.LAIR_ALREADY_DEFEATED)


func test_the_lair_holds_no_monsters() -> void:
	var empty := MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.MONSTER_LAIR)
	var page := _launch_after(func() -> void: game.levels[1].set_cell(lair_at.x, lair_at.y, empty))
	_assert_refused(page, Failure.LAIR_EMPTY)


func test_the_units_picked_are_no_longer_there() -> void:
	var page := _launch_after(func() -> void: give({Scout: 3, Harpoonist: 1}))
	_assert_refused(page, Failure.NOT_ENOUGH_UNITS)
	assert_eq(stock(Harpoonist), 1)


func test_launching_with_nothing_picked_is_refused() -> void:
	var page := open_selection()
	page.launch()
	_assert_refused(page, Failure.NO_UNIT_SELECTED)


func test_the_refusal_goes_with_a_new_pick_and_a_good_launch_goes_through() -> void:
	var page := _launch_after(func() -> void: give({Scout: 3, Harpoonist: 1}))
	page.rows[Harpoonist].set_value(1)
	assert_false(page.failure_label.visible)
	press("Lancer le combat")
	assert_true(current_modal() is FightSummaryPage)
