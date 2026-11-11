extends UnitTestCase
## The dialog that picks units to move (reinforcement_dialog_test.dart,
## unit_widgets_l10n_test.dart): title, rows, a confirm button that says the
## total and is dark while none is picked.

var _confirmed: Array[Dictionary] = []
var _results: Array[Variant] = []


func _units(scouts := 3, harpoonists := 2, guardians := 0) -> Dictionary[UnitType.Value, Unit]:
	return DomainSamples.units({Type.SCOUT: scouts, Type.HARPOONIST: harpoonists, Type.GUARDIAN: guardians})


func _open(dialog: UnitTransferDialog) -> UnitTransferDialog:
	modals().open(dialog)
	dialog.confirmed.connect(func(picks: Dictionary[UnitType.Value, int]) -> void: _confirmed.append(picks))
	dialog.closed.connect(_results.append)
	return dialog


func _dialog(units := _units()) -> UnitTransferDialog:
	return _open(UnitTransferDialog.new("Déplacer", units,
		func(total: int) -> String: return "Aller (%d)" % total, "Sous-titre"))


func test_shows_a_row_for_each_type_in_stock_and_none_for_the_others() -> void:
	var dialog := _dialog()
	assert_eq(dialog.rows.keys(), [Type.SCOUT, Type.HARPOONIST])
	assert_eq(dialog.title(), "Déplacer")
	assert_not_null(find_text("Sous-titre", dialog))
	assert_not_null(find_text("Stock : 3", dialog))


func test_the_confirm_button_is_dark_while_nothing_is_picked() -> void:
	var dialog := _dialog()
	assert_true(dialog.confirm_button.disabled)
	assert_eq(dialog.confirm_button.text, "Aller (0)")
	assert_eq(dialog.total(), 0)


func test_picking_units_lights_the_button_and_says_the_total() -> void:
	var dialog := _dialog()
	press(dialog.rows[Type.SCOUT].plus_button)
	assert_false(dialog.confirm_button.disabled)
	assert_eq(dialog.confirm_button.text, "Aller (1)")
	dialog.rows[Type.HARPOONIST].set_value(2)
	assert_eq(dialog.confirm_button.text, "Aller (3)")
	press(dialog.rows[Type.SCOUT].minus_button)
	press(dialog.rows[Type.HARPOONIST].minus_button)
	press(dialog.rows[Type.HARPOONIST].minus_button)
	assert_true(dialog.confirm_button.disabled, "dark again at none")


func test_confirming_tells_the_picks_that_are_not_zero_and_ends_with_them() -> void:
	var dialog := _dialog()
	dialog.rows[Type.SCOUT].set_value(2)
	dialog.rows[Type.HARPOONIST].set_value(1)
	dialog.rows[Type.HARPOONIST].set_value(0)
	press(dialog.confirm_button)
	var expected: Dictionary[UnitType.Value, int] = {Type.SCOUT: 2}
	assert_eq(_confirmed, [expected] as Array[Dictionary])
	assert_eq(_results, [expected] as Array[Variant])
	assert_true(dialog.is_closed())
	assert_null(current_modal())


func test_cancelling_ends_with_nothing_and_tells_nothing() -> void:
	var dialog := _dialog()
	dialog.rows[Type.SCOUT].set_value(2)
	press("Annuler")
	assert_eq(_confirmed.size(), 0)
	assert_eq(_results, [null] as Array[Variant])
	assert_true(dialog.is_closed())


func test_a_touch_outside_dismisses_it_without_picks() -> void:
	var dialog := _dialog()
	dialog.rows[Type.SCOUT].set_value(2)
	dialog.close()
	assert_eq(_results, [null] as Array[Variant])
	dialog.close(UnitTransferDialog.CONFIRM)
	assert_eq(_confirmed.size(), 0, "ended once")


func test_says_that_no_unit_is_available() -> void:
	var dialog := _dialog(_units(0, 0))
	assert_eq(dialog.rows.size(), 0)
	assert_not_null(find_text("Aucune unité disponible.", dialog))
	assert_true(dialog.confirm_button.disabled)


func test_has_no_header_without_subtitle_picture_or_notice() -> void:
	var dialog := _open(UnitTransferDialog.new("T", _units(), func(total: int) -> String: return str(total)))
	assert_eq(dialog.body.get_child(0), dialog.rows[Type.SCOUT])


func test_shows_the_picture_and_the_notice_it_is_given() -> void:
	var picture := Portrait.new("Faille", 48.0)
	var dialog := _open(UnitTransferDialog.new("T", _units(), func(total: int) -> String: return str(total),
		"", picture, Label.new()))
	assert_true(dialog.body.get_child(0).is_ancestor_of(picture))
	assert_true(dialog.body.get_child(1) is Label)
