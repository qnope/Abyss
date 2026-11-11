extends UiTestCase
## test/presentation/widgets/turn/turn_confirmation_dialog_test.dart: the
## question before the turn ends, with what it will make and cost.

const Res := ResourceType.Value

var _answers: Array = []


## The dialog for a turn 3 that will make [param production], shut down
## [param deactivated], take [param lost] and has [param explorations] scouts
## out (untyped collections: a typed one as a default argument leaks in 4.7).
func _open(production := {}, deactivated := [], lost := {}, explorations := 0, warnings := []) -> TurnConfirmation:
	var made: Dictionary[ResourceType.Value, int] = {}
	made.assign(production)
	var shut: Array[BuildingType.Value] = []
	shut.assign(deactivated)
	var units: Dictionary[UnitType.Value, int] = {}
	units.assign(lost)
	var shown: Array[Control] = []
	shown.assign(warnings)
	var dialog := TurnConfirmation.new(TurnForecast.new(3, made, shut, units, explorations), shown)
	dialog.closed.connect(_answers.append)
	modals().open(dialog)
	return dialog


func test_titles_the_turn_it_ends_and_the_one_it_begins() -> void:
	var dialog := _open()
	assert_eq(dialog.title(), "Tour 3 → Tour 4")
	assert_eq(current_modal(), dialog)


func test_lists_what_each_resource_will_make() -> void:
	_open({Res.ALGAE: 5, Res.CORAL: 8})
	assert_not_null(find_text("Algues"))
	assert_not_null(find_text("Corail"))
	assert_not_null(find_text("+5"))
	assert_not_null(find_text("+8"))
	assert_null(find_text("Aucune production ce tour."))


func test_says_when_nothing_will_be_made() -> void:
	_open()
	assert_not_null(find_text("Aucune production ce tour."))


func test_cancelling_answers_false_and_confirming_true() -> void:
	_open()
	press("Annuler")
	assert_eq(_answers, [false])
	assert_null(current_modal())
	_open()
	press("Confirmer")
	assert_eq(_answers, [false, true])


func test_dismissing_answers_nothing() -> void:
	_open()
	modals().close_top()
	assert_eq(_answers, [null])


func test_warns_of_the_buildings_the_lack_of_energy_shuts_down() -> void:
	_open({Res.ALGAE: 5}, [BuildingType.Value.ORE_EXTRACTOR])
	assert_not_null(find_text("Bâtiments désactivés"))
	assert_not_null(find_text("Extracteur de minerai"))
	assert_null(find_text("Unités perdues"))


func test_warns_of_the_units_the_lack_of_algae_takes() -> void:
	_open({Res.ALGAE: 5}, [], {UnitType.Value.SCOUT: 5})
	assert_not_null(find_text("Unités perdues"))
	assert_not_null(find_text("Éclaireur: -5"))
	assert_null(find_text("Bâtiments désactivés"))


func test_no_warning_when_nothing_is_lacking() -> void:
	_open({Res.ALGAE: 50})
	assert_not_null(find_text("+50"))
	assert_null(find_text("Bâtiments désactivés"))
	assert_null(find_text("Unités perdues"))


func test_counts_the_scouts_still_out() -> void:
	_open({Res.ALGAE: 5}, [], {}, 2)
	assert_not_null(find_text("2 explorations en attente"))
	assert_null(find_text("1 exploration en attente"))
	assert_null(find_text("0 exploration en attente"))


func test_shows_the_warnings_it_is_given_and_not_the_empty_message() -> void:
	var warning := Label.new()
	warning.text = "Une alerte"
	_open({}, [], {}, 0, [warning])
	assert_not_null(find_text("Une alerte"))
	assert_null(find_text("Aucune production ce tour."))


func test_follows_the_language_in_every_part() -> void:
	var dialog := _open({Res.ALGAE: 5}, [BuildingType.Value.ORE_EXTRACTOR], {UnitType.Value.SCOUT: 5}, 1)
	use_language("en")
	assert_eq(dialog.title(), "Turn 3 → Turn 4")
	for shown: String in ["Algae", "Buildings deactivated", "Ore Extractor", "Units lost", "Scout: -5",
			"1 pending exploration", "Cancel", "Confirm"]:
		assert_not_null(find_text(shown), shown)
	assert_no_raw_keys()
	use_language("es")
	assert_eq(dialog.title(), "Turno 3 → Turno 4")
	assert_no_raw_keys()
