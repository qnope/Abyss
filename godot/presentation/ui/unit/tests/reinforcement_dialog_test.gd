extends UnitTestCase
## test/presentation/screens/game/reinforcement_dialog_test.dart and
## transfer_dialog_illustration_test.dart, and the picker of
## unit_picker_dialog.dart.

var _confirmed: Array[Dictionary] = []


func _units() -> Dictionary[UnitType.Value, Unit]:
	return DomainSamples.units({Type.SCOUT: 3, Type.HARPOONIST: 2})


func _reinforcement(level := 2, name := "Base Alpha", picture: Control = null) -> ReinforcementDialog:
	var dialog := ReinforcementDialog.new(_units(), level, name, picture)
	modals().open(dialog)
	dialog.confirmed.connect(func(picks: Dictionary[UnitType.Value, int]) -> void: _confirmed.append(picks))
	return dialog


func test_shows_the_header_with_the_target_level_and_the_post() -> void:
	var dialog := _reinforcement(3, "Base Omega")
	assert_eq(dialog.title(), "Renforts vers le Niveau 3")
	assert_not_null(find_text("Base Omega", dialog))
	assert_no_raw_keys()


func test_displays_the_notice_of_the_transit_time() -> void:
	var dialog := _reinforcement()
	assert_not_null(find_text("Les renforts arriveront au prochain tour.", dialog))
	var banner := find_type("PanelContainer", dialog).filter(func(node: Node) -> bool:
		return node is NoticeBanner)
	assert_eq(banner.size(), 1)


func test_the_confirm_button_counts_the_units_in_the_plural_of_the_language() -> void:
	var dialog := _reinforcement()
	assert_eq(dialog.confirm_button.text, "Envoyer (0 unité)")
	assert_true(dialog.confirm_button.disabled)
	press(dialog.rows[Type.SCOUT].plus_button)
	assert_eq(dialog.confirm_button.text, "Envoyer (1 unité)")
	press(dialog.rows[Type.SCOUT].plus_button)
	assert_eq(dialog.confirm_button.text, "Envoyer (2 unités)")


func test_confirming_gives_the_units_picked() -> void:
	var dialog := _reinforcement()
	press(dialog.rows[Type.SCOUT].plus_button)
	press("Envoyer (1 unité)")
	var expected: Dictionary[UnitType.Value, int] = {Type.SCOUT: 1}
	assert_eq(_confirmed, [expected] as Array[Dictionary])
	assert_null(current_modal())


func test_cancelling_closes_without_confirming() -> void:
	var dialog := _reinforcement()
	press("Annuler")
	assert_eq(_confirmed.size(), 0)
	assert_true(dialog.is_closed())


func test_draws_the_picture_of_the_post_it_is_given() -> void:
	var picture := Portrait.new("Faille", 48.0)
	var dialog := _reinforcement(2, "Faille", picture)
	assert_true(dialog.is_ancestor_of(picture))


func test_reads_in_english_and_spanish() -> void:
	var dialog := _reinforcement()
	use_language("en")
	assert_eq(dialog.confirm_button.text, "Envoyer (0 unité)", "written when the dialog was built")
	var english := _reinforcement(2)
	assert_eq(english.title(), "Reinforcements to Level 2")
	assert_eq(english.confirm_button.text, "Send (0 units)")
	assert_no_raw_keys()
	use_language("es")
	assert_no_raw_keys(_reinforcement(2))


func test_the_picker_says_its_button_with_the_total_and_its_info() -> void:
	var dialog := UnitPickerDialog.new("Garnison", _units(), "Garnir", "Les unités restent au noyau.")
	modals().open(dialog)
	assert_eq(dialog.title(), "Garnison")
	assert_eq(dialog.confirm_button.text, "Garnir (0)")
	assert_not_null(find_text("Les unités restent au noyau.", dialog))
	dialog.rows[Type.HARPOONIST].set_value(2)
	assert_eq(dialog.confirm_button.text, "Garnir (2)")


func test_the_picker_has_no_info_line_without_info() -> void:
	var dialog := UnitPickerDialog.new("Garnison", _units(), "Garnir")
	modals().open(dialog)
	assert_eq(dialog.body.get_child(0), dialog.rows[Type.SCOUT])
