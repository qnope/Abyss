extends PostControllerCase
## test/presentation/screens/game/game_screen_garrison_kernel_test.dart and
## kernel_army_selection_screen_test.dart: the volcano of the map, the army
## sent against it, its garrison, and the game won with its last level.


func _tap_kernel() -> void:
	world.map.cell_tapped.emit(VOLCANO, kernel_at.x, kernel_at.y)


func test_a_touch_on_the_guarded_volcano_opens_its_sheet() -> void:
	_tap_kernel()
	assert_true(current_modal() is VolcanicKernelSheet)
	assert_not_null(find_text("Lancer l'assaut"))
	assert_null(find_text("Bientôt disponible"))


func test_the_assault_opens_the_army_of_the_volcano_level() -> void:
	var page := open_kernel_assault()
	assert_eq(page.title(), "Assaut : Noyau Volcanique")
	assert_eq(page.rows.keys(), [Harpoonist, Guardian, Admiral], "the units of the third level")
	assert_true(page.actions_bar.admiral_label.visible)


func test_a_won_assault_captures_the_kernel_and_opens_the_report() -> void:
	var page := open_kernel_assault()
	page.rows[Guardian].set_value(100)
	assault(page, Harpoonist, 150)
	var report := current_modal() as KernelFightSummaryPage
	assert_not_null(report)
	assert_true(report.result.captured)
	assert_not_null(find_text("NOYAU CAPTURÉ", report))
	assert_eq(on_level(VOLCANO, Harpoonist), 150 - report.result.dead.get(Harpoonist, 0))
	var cell := game.levels[VOLCANO].cell_at(kernel_at.x, kernel_at.y)
	assert_eq(cell.collected_by, human.id)
	assert_eq(saved().levels[VOLCANO].cell_at(kernel_at.x, kernel_at.y).collected_by, human.id, "saved")
	assert_no_raw_keys(report)


func test_a_lost_assault_leaves_the_kernel_to_the_kraken() -> void:
	human.units_per_level[VOLCANO] = DomainSamples.units({Scout: 1, Admiral: 1})
	var page := open_kernel_assault()
	page.rows[Admiral].set_value(1)
	press("Lancer l'assaut")
	var report := current_modal() as KernelFightSummaryPage
	assert_false(report.result.victory)
	assert_not_null(find_text("DÉFAITE", report))
	assert_null(game.levels[VOLCANO].cell_at(kernel_at.x, kernel_at.y).collected_by)
	assert_eq(on_level(VOLCANO, Admiral), 1 - report.result.dead.get(Admiral, 0))


func test_a_kernel_taken_meanwhile_is_refused_in_the_page() -> void:
	var page := open_kernel_assault()
	hold_kernel(1)
	page.rows[Admiral].set_value(1)
	press("Lancer l'assaut")
	assert_eq(current_modal(), page)
	assert_eq(page.failure_label.text, ActionFailureTexts.message(ActionFailure.Value.KERNEL_ALREADY_CAPTURED))


func test_cancelling_changes_nothing() -> void:
	open_kernel_assault()
	press("Annuler")
	assert_null(current_modal())
	assert_eq(on_level(VOLCANO, Harpoonist), 150)


func test_a_volcano_a_rival_holds_opens_the_attack_to_lot_13() -> void:
	var rival := game.players[game.factions()[0].id()]
	var cell := game.levels[VOLCANO].cell_at(kernel_at.x, kernel_at.y)
	game.levels[VOLCANO].set_cell(kernel_at.x, kernel_at.y, cell.copy_with({"collected_by": rival.id}))
	var told: Array[Array] = []
	controller.kernel.rival_attack_requested.connect(func(who: Player, level: int, x: int, y: int) -> void:
		told.append([who.id, level, x, y]))
	_tap_kernel()
	var sheet := current_modal() as RivalPostSheet
	assert_not_null(sheet)
	assert_null(sheet.base)
	assert_eq(sheet.held_label.text, "Tenue par %s" % rival.name)
	sheet.attack_button.disabled = false
	press("Attaquer")
	assert_eq(told, [[rival.id, VOLCANO, kernel_at.x, kernel_at.y]] as Array[Array])


func test_raising_the_kernel_to_the_last_level_opens_the_victory_screen() -> void:
	hold_kernel(9)
	for resource: GameResource in human.resources.values():
		resource.amount = resource.max_storage
	human.buildings[BuildingType.Value.HEADQUARTERS].level = 10
	hud.open_building(BuildingType.Value.VOLCANIC_KERNEL)
	press("Améliorer")
	assert_eq(game.status, GameStatus.Value.VICTORY)
	assert_true(current_modal() is VictoryScreen)
	assert_eq(saved().status, GameStatus.Value.VICTORY, "saved won")
