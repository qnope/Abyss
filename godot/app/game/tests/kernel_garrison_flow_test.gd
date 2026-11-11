extends PostControllerCase
## test/presentation/screens/game/game_screen_garrison_kernel_test.dart: the
## garrison of the kernel the player holds, filled and emptied through a picker.


func _tap_kernel() -> void:
	world.map.cell_tapped.emit(VOLCANO, kernel_at.x, kernel_at.y)


func test_a_held_kernel_shows_its_garrison() -> void:
	hold_kernel(3)
	_tap_kernel()
	var sheet := current_modal() as VolcanicKernelSheet
	assert_true(sheet.is_captured)
	assert_not_null(find_text("Noyau niveau 3"))
	assert_null(find_text("Lancer l'assaut"))


func test_putting_units_in_the_garrison_moves_them_and_tells_its_size() -> void:
	hold_kernel(3)
	_tap_kernel()
	press("Mettre en garnison")
	var picker := current_modal() as UnitPickerDialog
	assert_eq(picker.title(), "Mettre en garnison")
	picker.rows[Harpoonist].set_value(30)
	press("Envoyer (30)")
	assert_eq(on_level(VOLCANO, Harpoonist), 120)
	assert_eq(KernelGarrison.size_of(human), 30)
	assert_not_null(find_text("Garnison : 30 unités"))
	assert_eq(KernelGarrison.size_of(saved().human_player()), 30, "saved")


func test_withdrawing_brings_them_back_to_the_volcano_level() -> void:
	hold_kernel(3)
	_tap_kernel()
	press("Mettre en garnison")
	(current_modal() as UnitPickerDialog).rows[Harpoonist].set_value(30)
	press("Envoyer (30)")
	press("OK")
	_tap_kernel()
	press("Retirer")
	var picker := current_modal() as UnitPickerDialog
	assert_eq(picker.title(), "Retirer de la garnison")
	picker.rows[Harpoonist].set_value(10)
	press("Retirer (10)")
	assert_eq(KernelGarrison.size_of(human), 20)
	assert_eq(on_level(VOLCANO, Harpoonist), 130)
	assert_not_null(find_text("Garnison : 20 unités"))


func test_cancelling_the_picker_changes_nothing() -> void:
	hold_kernel(3)
	_tap_kernel()
	press("Mettre en garnison")
	press("Annuler")
	assert_null(current_modal())
	assert_eq(KernelGarrison.size_of(human), 0)


func test_a_kernel_not_built_refuses_the_garrison() -> void:
	hold_kernel(0)
	_tap_kernel()
	press("Mettre en garnison")
	(current_modal() as UnitPickerDialog).rows[Harpoonist].set_value(5)
	press("Envoyer (5)")
	assert_not_null(find_text(ActionFailureTexts.message(ActionFailure.Value.KERNEL_NOT_BUILT)))
	assert_eq(on_level(VOLCANO, Harpoonist), 150)
