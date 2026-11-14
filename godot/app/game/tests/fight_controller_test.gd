extends FightControllerCase
## test/presentation/screens/game/game_screen_fight_flow_test.dart: a lair of
## the map, the army sent against it, the report, and what the game kept.


func test_a_touch_on_a_lair_opens_its_sheet() -> void:
	world.map.cell_tapped.emit(1, lair_at.x, lair_at.y)
	assert_true(current_modal() is MonsterLairSheet)
	assert_not_null(find_text("Rôdeurs (%d, %d)" % [lair_at.x, lair_at.y]))
	assert_not_null(find_text("Préparer le combat"))


func test_preparing_opens_the_army_with_the_units_of_the_level() -> void:
	var page := open_selection()
	assert_eq(page.rows.keys(), [Scout, Harpoonist])
	assert_eq(depth(), 1, "the sheet is gone")
	assert_not_null(find_text("Rôdeurs · Facile", page), "the monsters are shown over the rows")
	assert_true(page.actions_bar.launch_button.disabled)


func test_cancelling_the_sheet_or_the_page_changes_nothing() -> void:
	world.map.cell_tapped.emit(1, lair_at.x, lair_at.y)
	press("Annuler")
	assert_null(current_modal())
	open_selection()
	press("Annuler")
	assert_null(current_modal())
	assert_eq(stock(Scout), 3)
	assert_false(game.levels[1].cell_at(lair_at.x, lair_at.y).is_collected())
	assert_eq(saved_games().size(), 0, "nothing was saved")


func test_a_victory_gives_the_loot_marks_the_lair_and_opens_the_report() -> void:
	var before := human.resources[ResourceType.Value.ALGAE].amount + human.resources[ResourceType.Value.CORAL].amount
	var page := open_selection()
	send(page, Harpoonist, 2)
	var report := current_modal() as FightSummaryPage
	assert_not_null(report)
	assert_eq(report.title(), "Combat (%d, %d)" % [lair_at.x, lair_at.y])
	assert_true(report.result.victory)
	assert_eq(stock(Harpoonist), 2 - report.result.dead.get(Harpoonist, 0))
	assert_eq(stock(Scout), 3, "the units kept home stay")
	assert_true(game.levels[1].cell_at(lair_at.x, lair_at.y).is_collected())
	var gained := 0
	for resource: ResourceType.Value in report.result.loot:
		gained += report.result.loot[resource]
	assert_true(gained > 0)
	assert_not_null(find_text("Butin", report))
	assert_true(human.resources[ResourceType.Value.ALGAE].amount + human.resources[ResourceType.Value.CORAL].amount >= before)
	assert_no_raw_keys(report)


func test_the_fight_is_saved_and_the_beaten_lair_is_dimmed_on_the_map() -> void:
	assert_false(MapProbe.is_dimmed(world.map.contents.by_cell[lair_at]))
	send(open_selection(), Harpoonist, 2)
	var kept := saved()
	assert_true(kept.levels[1].cell_at(lair_at.x, lair_at.y).is_collected())
	assert_eq(kept.human_player().units_on_level(1)[Harpoonist].count, stock(Harpoonist))
	assert_true(MapProbe.is_dimmed(world.map.contents.by_cell[lair_at]))
	assert_eq(kept.human_player().history_entries.size(), 1, "the fight is in the history")
	assert_true(kept.human_player().history_entries[0] is CombatEntry)


func test_a_defeat_costs_units_and_leaves_the_lair() -> void:
	put_lair(MonsterLair.new(MonsterDifficulty.Value.HARD, 300))
	give({Scout: 2})
	var page := open_selection()
	send(page, Scout, 1)
	var report := current_modal() as FightSummaryPage
	assert_false(report.result.victory)
	assert_not_null(find_text("DÉFAITE", report))
	assert_null(find_text("Butin", report))
	assert_eq(stock(Scout), 2 - report.result.dead.get(Scout, 0))
	assert_false(game.levels[1].cell_at(lair_at.x, lair_at.y).is_collected())
	assert_false(MapProbe.is_dimmed(world.map.contents.by_cell[lair_at]))
	assert_eq(saved().human_player().units_on_level(1)[Scout].count, stock(Scout))


func test_the_report_closes_back_to_the_map_and_the_lair_is_no_longer_one() -> void:
	send(open_selection(), Harpoonist, 2)
	press("Retour à la carte")
	assert_null(current_modal())
	world.map.cell_tapped.emit(1, lair_at.x, lair_at.y)
	assert_not_null(find_text("Déjà visité"))


func test_the_fights_report_is_what_the_history_reopens() -> void:
	send(open_selection(), Harpoonist, 2)
	var report := current_modal() as FightSummaryPage
	press("Retour à la carte")
	var entry := human.history_entries[0] as CombatEntry
	var again := HistoryReports.fight_summary(entry)
	modals().open(again)
	assert_eq(again.title(), report.title())
	assert_eq(again.result.victory, report.result.victory)
	assert_eq(again.result.loot, report.result.loot)
	assert_eq(again.result.sent, report.result.sent)


func depth() -> int:
	return modals().depth()
