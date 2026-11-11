extends PostControllerCase
## test/presentation/screens/game/game_screen_transition_actions_test.dart: the
## units that go down through a Faille the player holds, and the level the map
## then shows.


func test_a_held_faille_shows_its_descent_and_defence() -> void:
	hold_faille()
	world.map.cell_tapped.emit(1, faille_at.x, faille_at.y)
	assert_not_null(find_text("Capturée"))
	assert_not_null(find_text("Si la Faille tombe"))
	assert_not_null(find_text("Envoyer des unités au Niveau 2"))


func test_going_down_moves_the_units_shows_the_level_and_saves() -> void:
	hold_faille()
	world.map.cell_tapped.emit(1, faille_at.x, faille_at.y)
	press("Envoyer des unités au Niveau 2")
	var dialog := current_modal() as DescentDialog
	assert_not_null(dialog)
	assert_eq(dialog.title(), "Descente vers le Niveau 2")
	dialog.rows[Harpoonist].set_value(40)
	press("Descendre (40 unités)")
	assert_eq(on_level(1, Harpoonist), 110)
	assert_eq(on_level(2, Harpoonist), 40)
	assert_eq(controller.map.tab.level, 2, "the map shows the level reached")
	assert_not_null(find_text("Descente au Niveau 2 effectuée"))
	assert_eq(saved().human_player().units_on_level(2)[Harpoonist].count, 40)
	assert_true(saved().human_player().history_entries.any(func(e: HistoryEntry) -> bool: return e is DescentEntry))


func test_a_descent_refused_is_told() -> void:
	hold_faille()
	world.map.cell_tapped.emit(1, faille_at.x, faille_at.y)
	press("Envoyer des unités au Niveau 2")
	var dialog := current_modal() as DescentDialog
	dialog.rows[Harpoonist].set_value(40)
	human.buildings.erase(BuildingType.Value.DESCENT_MODULE)
	press("Descendre (40 unités)")
	assert_not_null(find_text(ActionFailureTexts.message(ActionFailure.Value.REQUIRED_BUILDING_MISSING)))
	assert_eq(on_level(1, Harpoonist), 150)
	assert_eq(controller.map.tab.level, 1)


func test_cancelling_the_descent_changes_nothing() -> void:
	hold_faille()
	world.map.cell_tapped.emit(1, faille_at.x, faille_at.y)
	press("Envoyer des unités au Niveau 2")
	press("Annuler")
	assert_null(current_modal())
	assert_eq(on_level(1, Harpoonist), 150)
