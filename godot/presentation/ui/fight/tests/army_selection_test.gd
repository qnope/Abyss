extends UiTestCase
## test/presentation/screens/game/fight/army_selection_screen_test.dart: the
## page where the army to send is picked, whatever it is sent against.

const Scout := UnitType.Value.SCOUT
const Harpoonist := UnitType.Value.HARPOONIST

var _asked: Array[Dictionary] = []
var _closed: Array[Variant] = []
## What the confirmation answers: a success, or a failure for a reason.
var _answer := ActionResult.success()


func _confirm(picks: Dictionary[UnitType.Value, int]) -> ActionResult:
	_asked.append(picks)
	return _answer


func _page(stock: Dictionary[UnitType.Value, int], military_level := 0) -> ArmySelection:
	var player := ActionSamples.fight_player(stock, military_level)
	var page := ArmySelection.new(Texts.t.bind(&"fightPrepare"), player.units_on_level(1),
		ArmySelectionSummary.boost_of(player), &"fightLaunch", _confirm, Label.new())
	page.closed.connect(_closed.append)
	modals().open(page)
	return page


func test_the_page_lists_the_types_in_stock_only() -> void:
	var page := _page({Scout: 3, Harpoonist: 2})
	assert_eq(page.title(), "Préparer le combat")
	assert_eq(page.rows.keys(), [Scout, Harpoonist])
	assert_not_null(find_text("Éclaireur", page))
	assert_null(find_text("Gardien", page))
	page = _page({Scout: 2})
	assert_eq(page.rows.keys(), [Scout])
	assert_null(find_text("Briseur", page))
	assert_no_raw_keys(page)


func test_the_header_comes_before_the_rows() -> void:
	var page := _page({Scout: 1})
	assert_true(page.body.get_child(0) is Label)


func test_launching_waits_for_a_unit() -> void:
	var page := _page({Scout: 3})
	assert_true(page.actions_bar.launch_button.disabled)
	page.rows[Scout].plus_button.pressed.emit()
	assert_false(page.actions_bar.launch_button.disabled)
	page.rows[Scout].minus_button.pressed.emit()
	assert_true(page.actions_bar.launch_button.disabled)


func test_the_totals_follow_the_picks() -> void:
	var page := _page({Scout: 3})
	assert_eq(page.summary.atk_value.text, "0")
	page.rows[Scout].plus_button.pressed.emit()
	assert_eq(page.summary.atk_value.text, "2")
	page.rows[Scout].plus_button.pressed.emit()
	assert_eq(page.summary.atk_value.text, "4")
	assert_eq(page.summary.def_value.text, "2")


func test_the_military_research_is_in_the_totals_and_the_bonus() -> void:
	var page := _page({Harpoonist: 2}, 5)
	page.rows[Harpoonist].plus_button.pressed.emit()
	assert_eq(page.summary.atk_value.text, "10")
	assert_eq(page.boost.atk_percent, 95)
	assert_true(page.summary.bonus_label.text.contains("+95% ATK"))


func test_launching_asks_with_the_units_picked_and_ends_with_the_answer() -> void:
	var page := _page({Scout: 3, Harpoonist: 2})
	page.rows[Scout].set_value(2)
	press("Lancer le combat")
	assert_eq(_asked, [{Scout: 2}] as Array[Dictionary])
	assert_eq(_closed, [_answer] as Array[Variant])
	assert_true(page.is_closed())


func test_a_refusal_is_told_in_the_page_and_the_page_stays() -> void:
	_answer = ActionResult.failure(ActionFailure.Value.NOT_ENOUGH_UNITS)
	var page := _page({Scout: 3})
	page.rows[Scout].set_value(1)
	press("Lancer le combat")
	assert_true(page.failure_label.visible)
	assert_eq(page.failure_label.text, ActionFailureTexts.message(ActionFailure.Value.NOT_ENOUGH_UNITS))
	assert_false(page.is_closed())
	assert_eq(_closed.size(), 0)
	page.rows[Scout].set_value(2)
	assert_false(page.failure_label.visible, "a new pick takes the refusal away")


func test_a_refusal_follows_the_language() -> void:
	_answer = ActionResult.failure(ActionFailure.Value.LAIR_EMPTY)
	var page := _page({Scout: 3})
	page.launch()
	use_language("en")
	assert_eq(page.failure_label.text, ActionFailureTexts.message(ActionFailure.Value.LAIR_EMPTY))
	assert_eq(page.title(), "Prepare the fight")
	assert_no_raw_keys(page)


func test_cancelling_ends_the_page_with_nothing_asked() -> void:
	var page := _page({Scout: 3})
	press("Annuler")
	assert_true(page.is_closed())
	assert_eq(_closed, [null] as Array[Variant])
	assert_eq(_asked.size(), 0)
	page = _page({Scout: 3})
	press(page.back_button)
	assert_true(page.is_closed())
