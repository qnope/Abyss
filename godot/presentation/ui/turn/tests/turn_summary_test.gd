extends UiTestCase
## test/presentation/widgets/turn/turn_summary_dialog_test.dart: what the turn
## did, once it ended.

const Res := ResourceType.Value

var _answers: Array = []


## A turn 3 -> 4 that did [param changes], shut [param deactivated] down and
## lost [param lost] (untyped collections, built typed here).
func _result(changes := [], recruited := false, deactivated := [], lost := {}) -> TurnResult:
	var made: Array[TurnResourceChange] = []
	made.assign(changes)
	var shut: Array[BuildingType.Value] = []
	shut.assign(deactivated)
	var units: Dictionary[UnitType.Value, int] = {}
	units.assign(lost)
	return TurnResult.new(made, 3, 4, recruited, shut, units)


func _change(type := Res.ALGAE, produced := 50, consumed := 0, capped := false) -> TurnResourceChange:
	return TurnResourceChange.new(type, produced, capped, 100, 150, consumed)


func _show(result: TurnResult) -> TurnSummary:
	var dialog := TurnSummary.new(result)
	dialog.closed.connect(_answers.append)
	modals().open(dialog)
	return dialog


func test_titles_the_turn_that_ended_and_the_one_that_began() -> void:
	assert_eq(_show(_result([_change()])).title(), "Tour 3 → Tour 4")


func test_lists_the_resources_gained() -> void:
	_show(_result([_change(Res.ALGAE, 5), _change(Res.CORAL, 8)]))
	for shown: String in ["Algues", "Corail", "+5", "+8"]:
		assert_not_null(find_text(shown), shown)


func test_tells_a_full_stock() -> void:
	_show(_result([_change(Res.ALGAE, 50, 0, true)]))
	assert_not_null(find_text("(max atteint)"))


func test_hides_the_full_stock_note_when_the_stock_was_not_full() -> void:
	_show(_result([_change()]))
	assert_null(find_text("(max atteint)"), "the label is hidden, not absent")


func test_tells_what_was_spent() -> void:
	_show(_result([_change(Res.ENERGY, 18, 8)]))
	assert_not_null(find_text("+18/-8"))


func test_offers_the_recruitment_that_opened() -> void:
	_show(_result([_change()], true))
	assert_not_null(find_text("Recrutement disponible"))


func test_hides_the_recruitment_when_none_opened() -> void:
	_show(_result([_change()]))
	assert_null(find_text("Recrutement disponible"))


func test_says_that_nothing_changed() -> void:
	_show(_result())
	assert_not_null(find_text("Aucun changement ce tour."))


func test_the_recruitment_alone_is_a_change() -> void:
	_show(_result([], true))
	assert_not_null(find_text("Recrutement disponible"))
	assert_null(find_text("Aucun changement ce tour."))


func test_lists_the_buildings_shut_down_and_the_units_lost() -> void:
	_show(_result([_change()], false, [BuildingType.Value.CORAL_MINE], {UnitType.Value.GUARDIAN: 3}))
	for shown: String in ["Bâtiments désactivés", "Mine de corail", "Unités perdues", "Gardien: -3"]:
		assert_not_null(find_text(shown), shown)


func test_no_loss_section_when_nothing_was_lost() -> void:
	_show(_result([_change()]))
	assert_null(find_text("Bâtiments désactivés"))
	assert_null(find_text("Unités perdues"))


func test_ok_ends_it() -> void:
	_show(_result([_change()]))
	press("OK")
	assert_eq(_answers, [null])
	assert_null(current_modal())


func test_follows_the_language() -> void:
	var dialog := _show(_result([_change(Res.ENERGY, 18, 8, true)], true, [BuildingType.Value.CORAL_MINE], {UnitType.Value.GUARDIAN: 3}))
	use_language("en")
	assert_eq(dialog.title(), "Turn 3 → Turn 4")
	for shown: String in ["Energy", "+18/-8", "(max reached)", "Coral Mine", "Guardian: -3", "Recruitment available"]:
		assert_not_null(find_text(shown), shown)
	assert_no_raw_keys()
	use_language("es")
	assert_eq(dialog.title(), "Turno 3 → Turno 4")
	assert_no_raw_keys()
