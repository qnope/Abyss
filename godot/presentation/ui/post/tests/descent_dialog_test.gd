extends UiTestCase
## test/presentation/screens/game/descent_dialog_test.dart: the units that go
## down for good through a captured post.

const Scout := UnitType.Value.SCOUT
const Harpoonist := UnitType.Value.HARPOONIST

var _picks: Array[Dictionary] = []


func _dialog(base: TransitionBase = null) -> DescentDialog:
	if base == null:
		base = TransitionBase.new(TransitionBaseType.Value.FAILLE, "faille_beta", "me")
	var stock := DomainSamples.units({Scout: 4, Harpoonist: 0})
	var dialog := DescentDialog.new(stock, base.target_level(), base)
	dialog.confirmed.connect(_picks.append)
	modals().open(dialog)
	return dialog


func test_the_header_names_the_level_and_the_post() -> void:
	var dialog := _dialog()
	assert_eq(dialog.title(), "Descente vers le Niveau 2")
	assert_not_null(find_text(TransitionBaseNameTexts.label("faille_beta"), dialog))
	assert_not_null(find_text("Attention : la descente est définitive. Les unités ne pourront pas remonter.", dialog))
	assert_no_raw_keys(dialog)


func test_a_cheminee_goes_to_level_3() -> void:
	var dialog := _dialog(TransitionBase.new(TransitionBaseType.Value.CHEMINEE, "cheminee_primary", "me"))
	assert_eq(dialog.title(), "Descente vers le Niveau 3")


func test_confirming_waits_for_a_unit() -> void:
	var dialog := _dialog()
	assert_true(dialog.confirm_button.disabled)
	assert_eq(dialog.confirm_button.text, "Descendre (0 unité)")
	dialog.rows[Scout].set_value(2)
	assert_false(dialog.confirm_button.disabled)
	assert_eq(dialog.confirm_button.text, "Descendre (2 unités)")


func test_only_the_types_in_stock_are_offered() -> void:
	assert_eq(_dialog().rows.keys(), [Scout])


func test_confirming_tells_the_picks_and_ends_the_dialog() -> void:
	var dialog := _dialog()
	dialog.rows[Scout].set_value(3)
	press("Descendre (3 unités)")
	assert_eq(_picks, [{Scout: 3}] as Array[Dictionary])
	assert_true(dialog.is_closed())


func test_cancelling_tells_nothing() -> void:
	var dialog := _dialog()
	press("Annuler")
	assert_eq(_picks.size(), 0)
	assert_true(dialog.is_closed())
