extends TestCase
## What the digest test of the objectives does between the turns, and its texts.

const Type := BuildingType.Value


func test_develops_a_player_turn_by_turn() -> void:
	var game := ObjectiveSamples.objective_game()
	var p := game.human_player()
	var revealed := p.revealed_cells_on_level(1).size()
	ObjectiveDigests.develop(game, p, 4, 0)
	assert_eq(p.buildings[Type.SOLAR_PANEL].level, 1)
	assert_true(p.tech_branches[TechBranch.Value.MILITARY].unlocked)
	assert_eq(p.tech_branches[TechBranch.Value.MILITARY].research_level, 1)
	assert_eq(p.revealed_cells_on_level(1).size(), revealed + 14)
	ObjectiveDigests.develop(game, p, 6, 0)
	assert_eq(p.units_on_level(1)[UnitType.Value.SCOUT].count, 1)
	assert_true(p.raid_state.is_incoming())
	ObjectiveDigests.develop(game, p, 8, 0)
	assert_eq([p.raid_state.raids_repelled, p.raid_state.is_incoming()], [1, false])
	ObjectiveDigests.develop(game, p, 9, 0)
	ObjectiveDigests.develop(game, p, 11, 0)
	assert_eq(p.history_entries.size(), 2)
	ObjectiveDigests.develop(game, p, 13, 0)
	assert_eq(p.raid_state.lost_in_a_row, 1)
	ObjectiveDigests.develop(game, p, 16, 0)
	assert_eq(p.units_on_level(2)[UnitType.Value.HARPOONIST].count, 3)


func test_takes_the_first_lair_faille_and_kernel_no_one_holds() -> void:
	var game := ObjectiveSamples.objective_game()
	var p := game.human_player()
	var map: GameMap = game.levels[1]
	map.set_cell(2, 0, map.cell_at(2, 0).copy_with({"content": CellContentType.Value.MONSTER_LAIR}))
	map.set_cell(3, 0, map.cell_at(3, 0).copy_with({"content": CellContentType.Value.VOLCANIC_KERNEL}))
	var faille := TransitionBase.new(TransitionBaseType.Value.FAILLE, "faille:0")
	map.set_cell(4, 0, map.cell_at(4, 0).copy_with({"transition_base": faille}))
	ObjectiveDigests.develop(game, p, 10, 0)
	ObjectiveDigests.develop(game, p, 14, 0)
	ObjectiveDigests.develop(game, p, 18, 0)
	assert_eq([map.cell_at(2, 0).collected_by, map.cell_at(3, 0).collected_by], [p.id, p.id])
	assert_eq(faille.captured_by, p.id)


func test_writes_completions_objectives_of_the_events_and_tips() -> void:
	var game := ObjectiveSamples.objective_game()
	var p := game.human_player()
	ObjectiveSamples.set_building(p, Type.ALGAE_FARM, 1)
	var done := ObjectiveResolver.resolve(game, p)
	assert_eq(ObjectiveDigests.completion(3, done[0]), "3 +algaeFarm coral:30 ore:20")
	done[0].credited.clear()
	assert_eq(ObjectiveDigests.completion(3, done[0]), "3 +algaeFarm")
	var wreck := TemporaryObjective.new(TemporaryObjectiveKind.Value.WRECK, 9)
	assert_eq(ObjectiveDigests.temporary(5, wreck), "5 ~wreck/9")
	assert_eq(ObjectiveDigests.temporary(9, wreck, TemporaryObjectiveOutcome.Value.EXPIRED), "9 -wreck/9 expired")
	var seen: Dictionary[TipId.Value, bool] = {}
	p.raid_state.noise = 100
	assert_eq(ObjectiveDigests.fresh_tips(game, p, 2, seen), "2 !noiseGauge")
	assert_eq(ObjectiveDigests.fresh_tips(game, p, 3, seen), "")
