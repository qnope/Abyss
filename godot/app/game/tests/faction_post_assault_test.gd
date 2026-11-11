extends FactionControllerCase
## game_screen_post_actions_test.dart and game_screen_rival_fight_flow_test.dart:
## the Faille and the volcano another player holds, attacked from their sheet.


func _open_faille_assault() -> ArmySelection:
	rival_holds_faille()
	world.map.cell_tapped.emit(1, faille_at.x, faille_at.y)
	press("Attaquer")
	return current_modal() as ArmySelection


func _open_kernel_assault() -> ArmySelection:
	rival_holds_kernel(2)
	world.map.cell_tapped.emit(VOLCANO, kernel_at.x, kernel_at.y)
	press("Attaquer")
	return current_modal() as ArmySelection


func test_the_attack_on_a_faille_opens_the_army_of_its_level() -> void:
	var page := _open_faille_assault()
	assert_not_null(page)
	assert_eq(page.title(), "Assaut : %s" % rival.name)
	assert_eq(page.rows.keys(), [Scout, Harpoonist, Guardian, Admiral])
	assert_false(page.needs_admiral)
	assert_eq(modals().depth(), 1, "the sheet is gone")


func test_a_won_assault_takes_the_faille_and_names_it_in_the_report() -> void:
	var page := _open_faille_assault()
	var before := on_level(1, Harpoonist)
	strike(page, Harpoonist, 150)
	var report := current_modal() as BaseAssaultSummaryPage
	assert_not_null(report)
	assert_true(report.victory)
	assert_eq(report.entry.post_name, faille().name)
	assert_eq(faille().captured_by, human.id, "the domain gave it to the player")
	assert_eq(on_level(1, Harpoonist), before - report.entry.dead.get(Harpoonist, 0))
	assert_not_null(find_text("VICTOIRE", report))
	assert_true(says(report, "est à vous"))
	assert_eq(find_type("AssaultDamageCard", report).size(), 0, "no base to damage")
	assert_eq(saved().levels[1].cell_at(faille_at.x, faille_at.y).transition_base.captured_by, human.id)
	assert_true(assaults(rival)[0].defending)
	assert_no_raw_keys(report)


func test_a_lost_assault_leaves_the_faille_to_the_rival() -> void:
	var page := _open_faille_assault()
	AssaultSamples.station(rival, AssaultSamples.WALL)
	rival.units_per_level[2] = DomainSamples.units(AssaultSamples.WALL)
	strike(page, Harpoonist, 3)
	var report := current_modal() as BaseAssaultSummaryPage
	assert_false(report.victory)
	assert_not_null(find_text("DÉFAITE", report))
	assert_eq(faille().captured_by, rival.id)


func test_the_attack_on_the_volcano_opens_the_army_of_the_volcano_level() -> void:
	var page := _open_kernel_assault()
	assert_eq(page.title(), "Assaut : %s" % rival.name)
	assert_eq(page.rows.keys(), [Harpoonist, Guardian, Admiral])
	assert_false(page.needs_admiral)


func test_a_won_assault_on_the_kernel_tells_the_level_it_lost() -> void:
	var page := _open_kernel_assault()
	var before := on_level(VOLCANO, Harpoonist)
	strike(page, Harpoonist, 150)
	var report := current_modal() as BaseAssaultSummaryPage
	assert_not_null(report)
	assert_eq(report.entry.post_name, AttackHeldKernelAction.KERNEL_CODE)
	assert_true(report.victory)
	assert_not_null(find_text("Noyau : niveau 2 → %d" % report.entry.rampart_after, report))
	assert_eq(on_level(VOLCANO, Harpoonist), before - report.entry.dead.get(Harpoonist, 0))
	assert_eq(rival.buildings[BuildingType.Value.VOLCANIC_KERNEL].level, report.entry.rampart_after)
	assert_eq(saved().human_player().units_on_level(VOLCANO)[Harpoonist].count, on_level(VOLCANO, Harpoonist))
	assert_no_raw_keys(report)


func test_a_refusal_of_the_kernel_assault_is_told_in_the_page() -> void:
	var page := _open_kernel_assault()
	page.rows[Harpoonist].set_value(10)
	human.units_per_level[VOLCANO] = DomainSamples.units({Harpoonist: 5})
	press("Lancer l'assaut")
	assert_eq(current_modal(), page)
	assert_eq(page.failure_label.text, ActionFailureTexts.message(ActionFailure.Value.NOT_ENOUGH_UNITS))
	assert_eq(rival.buildings[BuildingType.Value.VOLCANIC_KERNEL].level, 2)
