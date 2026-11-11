extends BuildingTestCase
## Raising a building from its sheet (building_detail_sheet_test.dart,
## game_screen_actions): the game changes through the actions, the sheet
## closes; a refusal is told in the sheet, which is read again.

const Type := BuildingType.Value
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


func _ready_sheet(type: BuildingType.Value) -> BuildingSheet:
	actions.acted.connect(_count)
	var sheet := open_sheet(type)
	sheet.closed.connect(_results.append)
	return sheet


func test_builds_a_building_that_was_not_there() -> void:
	var sheet := _ready_sheet(Type.HEADQUARTERS)
	assert_eq(human.buildings[Type.HEADQUARTERS].level, 0)
	press("Construire")
	assert_eq(human.buildings[Type.HEADQUARTERS].level, 1)
	assert_eq(human.worksite.upgrades, 1)
	assert_eq(_acted, 1, "told once, for the owner to save and redraw")
	assert_true(sheet.is_closed())
	assert_null(current_modal())


func test_pays_the_cost_and_closes_with_the_result() -> void:
	set_levels({Type.HEADQUARTERS: 1})
	fill_stores()
	var cost := view_of(Type.HEADQUARTERS).calculator.upgrade_cost(Type.HEADQUARTERS, 1)
	var coral: int = human.resources[ResourceType.Value.CORAL].amount
	_ready_sheet(Type.HEADQUARTERS)
	press("Améliorer")
	assert_eq(human.buildings[Type.HEADQUARTERS].level, 2)
	assert_eq(human.resources[ResourceType.Value.CORAL].amount, coral - cost.get(ResourceType.Value.CORAL, 0))
	assert_eq(_results.size(), 1)
	var result: ActionResult = _results[0]
	assert_true(result.is_success)


func test_a_building_that_cannot_rise_has_a_dark_button() -> void:
	_ready_sheet(Type.LABORATORY)
	assert_true(UiButtons.under(find_text("Construire")).disabled)
	assert_eq(_acted, 0)


func test_tells_that_the_worksites_are_busy_and_reads_the_game_again() -> void:
	set_levels({Type.HEADQUARTERS: 1})
	fill_stores()
	var sheet := _ready_sheet(Type.HEADQUARTERS)
	human.worksite.upgrades = 1
	press("Améliorer")
	assert_eq(sheet.failure, ActionFailureTexts.message(Failure.WORKSITES_BUSY))
	assert_not_null(find_text(sheet.failure, sheet))
	assert_not_null(find_text("Chantiers occupés ce tour", sheet), "the section is drawn again")
	assert_eq(human.buildings[Type.HEADQUARTERS].level, 1)
	assert_false(sheet.is_closed())
	assert_eq(_acted, 0)


func test_tells_that_the_top_level_is_reached() -> void:
	set_levels({Type.HEADQUARTERS: 10, Type.ALGAE_FARM: 4})
	fill_stores()
	var sheet := _ready_sheet(Type.ALGAE_FARM)
	human.buildings[Type.ALGAE_FARM].level = 5
	press("Améliorer")
	assert_not_null(find_text(ActionFailureTexts.message(Failure.MAX_LEVEL_REACHED), sheet))
	assert_not_null(find_text("Niveau maximum atteint", sheet))


func test_tells_that_the_stock_is_short() -> void:
	set_levels({Type.HEADQUARTERS: 1})
	fill_stores()
	var sheet := _ready_sheet(Type.HEADQUARTERS)
	human.resources[ResourceType.Value.CORAL].amount = 0
	press("Améliorer")
	assert_not_null(find_text(ActionFailureTexts.message(Failure.NOT_ENOUGH_RESOURCES), sheet))


func test_the_refusal_follows_the_language_not_the_state() -> void:
	set_levels({Type.HEADQUARTERS: 1})
	fill_stores()
	var sheet := _ready_sheet(Type.HEADQUARTERS)
	human.worksite.upgrades = 1
	press("Améliorer")
	use_language("en")
	assert_not_null(find_text("Worksites busy this turn", sheet))
