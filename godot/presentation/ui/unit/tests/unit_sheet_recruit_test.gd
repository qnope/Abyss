extends UnitTestCase
## Recruiting from the sheet of a unit (game_screen_army_test.dart, the
## recruit units test): the game changes through the actions and the sheet
## closes; a refusal is told in the sheet, which is read again.

const Failure := ActionFailure.Value

var _acted := 0
var _results: Array[Variant] = []


func after_each() -> void:
	if actions.acted.is_connected(_count):
		actions.acted.disconnect(_count)
	_acted = 0
	_results.clear()


func _count(_result: Variant) -> void:
	_acted += 1


func _ready_sheet(type: UnitType.Value, count := 0) -> UnitSheet:
	actions.acted.connect(_count)
	var sheet := open_sheet(type, count)
	sheet.closed.connect(_results.append)
	return sheet


func _recruit(sheet: UnitSheet, quantity: int) -> void:
	slider_in(sheet).value = quantity
	press("Recruter")


func test_recruits_the_units_pays_for_them_and_closes_with_the_result() -> void:
	var algae: int = human.resources[ResourceType.Value.ALGAE].amount
	var sheet := _ready_sheet(Type.SCOUT)
	_recruit(sheet, 3)
	assert_eq(units_at(Type.SCOUT), 3)
	assert_eq(human.resources[ResourceType.Value.ALGAE].amount, algae - 30)
	assert_true(human.recruited_unit_types.has(Type.SCOUT))
	assert_eq(_acted, 1, "told once, for the owner to save and redraw")
	assert_true(sheet.is_closed())
	assert_null(current_modal())
	assert_eq(_results.size(), 1)
	var result: ActionResult = _results[0]
	assert_true(result.is_success)


func test_recruiting_nothing_is_not_offered() -> void:
	_ready_sheet(Type.SCOUT)
	assert_true(UiButtons.under(find_text("Recruter")).disabled)
	assert_eq(_acted, 0)


func test_tells_that_the_barracks_is_too_low_and_reads_the_game_again() -> void:
	var sheet := _ready_sheet(Type.SCOUT)
	slider_in(sheet).value = 2
	human.buildings[Barracks].level = 0
	press("Recruter")
	assert_eq(sheet.failure, ActionFailureTexts.message(Failure.UNIT_LOCKED))
	assert_not_null(find_text(sheet.failure, sheet))
	assert_not_null(find_text("Caserne niveau 1 requise pour débloquer", sheet))
	assert_eq(units_at(Type.SCOUT), 0)
	assert_false(sheet.is_closed())
	assert_eq(_acted, 0)


func test_tells_that_the_type_was_recruited_this_turn() -> void:
	var sheet := _ready_sheet(Type.SCOUT)
	slider_in(sheet).value = 2
	human.recruited_unit_types.append(Type.SCOUT)
	press("Recruter")
	assert_not_null(find_text(ActionFailureTexts.message(Failure.RECRUITMENT_ALREADY_DONE), sheet))
	assert_not_null(find_text("Recrutement déjà effectué ce tour", sheet))
	assert_eq(_acted, 0)


func test_tells_that_the_stock_is_short() -> void:
	var sheet := _ready_sheet(Type.SCOUT)
	slider_in(sheet).value = 10
	human.resources[ResourceType.Value.CORAL].amount = 0
	press("Recruter")
	assert_not_null(find_text(ActionFailureTexts.message(Failure.NOT_ENOUGH_RESOURCES), sheet))
	assert_not_null(find_text("Ressources insuffisantes", sheet))
	assert_eq(units_at(Type.SCOUT), 0)


func test_tells_that_the_quantity_is_not_one() -> void:
	var sheet := _ready_sheet(Type.SCOUT)
	section_in(sheet).recruit_pressed.emit(0)
	assert_not_null(find_text(ActionFailureTexts.message(Failure.INVALID_QUANTITY), sheet))
	assert_eq(_acted, 0)


func test_the_refusal_follows_the_language_not_the_state() -> void:
	var sheet := _ready_sheet(Type.SCOUT)
	slider_in(sheet).value = 2
	human.recruited_unit_types.append(Type.SCOUT)
	press("Recruter")
	use_language("en")
	assert_not_null(find_text(ActionFailureTexts.message(Failure.RECRUITMENT_ALREADY_DONE), sheet))
	assert_not_null(find_text("Already recruited this turn", sheet))


func test_a_recruit_arrives_on_the_first_level_whatever_the_count_shown() -> void:
	human.units_per_level[2] = DomainSamples.units({Type.SCOUT: 5})
	var sheet := _ready_sheet(Type.SCOUT, 5)
	_recruit(sheet, 1)
	assert_eq(units_at(Type.SCOUT, 1), 1)
	assert_eq(units_at(Type.SCOUT, 2), 5)
