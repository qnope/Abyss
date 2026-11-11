extends TestCase
## Not in the Dart files (tutorial_strategy_test.dart ends turns, which
## waits for `turn`): the step of the guide a newcomer follows, what each
## step plays, and the harpoonists recruited on the guide's advice.

const Id := ObjectiveId.Value
const Type := BuildingType.Value
const HARPOONIST := UnitType.Value.HARPOONIST


func _turn() -> ScriptTurn:
	var game := GameFactory.new_single_player("p", 5, Difficulty.Value.NORMAL, true)
	var player := game.human_player()
	for r: GameResource in player.resources.values():
		r.amount = r.max_storage
	return ScriptSamples.turn(game)


func _level(turn: ScriptTurn, type: Type) -> int:
	return turn.player.buildings[type].level


func test_the_step_is_the_first_objective_not_completed_until_a_raid_is_fought() -> void:
	var turn := _turn()
	var state := ObjectiveMigration.state_of(turn.game, turn.player)
	assert_eq(TutorialMoves.tutorial_step(turn).id, Id.HQ_LEVEL_1)
	state.completed.append(Id.HQ_LEVEL_1)
	assert_eq(TutorialMoves.tutorial_step(turn).id, Id.ALGAE_FARM)
	for objective: Objective in InstallationObjectives.installation_objectives():
		state.completed.append(objective.id)
	assert_null(TutorialMoves.tutorial_step(turn))
	var fought := _turn()
	fought.player.raid_state.raids_lost = 1
	assert_null(TutorialMoves.tutorial_step(fought))
	var repelled := _turn()
	repelled.player.raid_state.raids_repelled = 1
	assert_null(TutorialMoves.tutorial_step(repelled))


func test_each_step_raises_what_it_asks_once() -> void:
	var cases: Dictionary[Id, Array] = {
		Id.HQ_LEVEL_1: [Type.HEADQUARTERS, 1], Id.ALGAE_FARM: [Type.ALGAE_FARM, 1],
		Id.MINES: [Type.CORAL_MINE, 1], Id.SOLAR_PANEL: [Type.SOLAR_PANEL, 1],
	}
	for id: Id in cases:
		var turn := _turn()
		var type: Type = cases[id][0]
		if id != Id.HQ_LEVEL_1:
			turn.player.buildings[Type.HEADQUARTERS].level = 1
		TutorialMoves.follow_step(turn, id)
		assert_eq(_level(turn, type), cases[id][1], DartEnum.name_of(Id, id))
	var done := _turn()
	done.player.buildings[Type.HEADQUARTERS].level = 3
	done.player.worksite.upgrades = 0
	TutorialMoves.follow_step(done, Id.HQ_LEVEL_2)
	TutorialMoves.follow_step(done, Id.FIRST_RAID)
	assert_eq(_level(done, Type.HEADQUARTERS), 3)
	assert_eq(done.player.worksite.upgrades, 0)


func test_the_later_steps_build_recruit_explore_and_research() -> void:
	var turn := _turn()
	var buildings := turn.player.buildings
	buildings[Type.HEADQUARTERS].level = 3
	buildings[Type.BARRACKS].level = 1
	buildings[Type.SOLAR_PANEL].level = 1
	TutorialMoves.follow_step(turn, Id.BARRACKS_AND_SCOUTS)
	assert_eq(turn.player.units_on_level(1)[UnitType.Value.SCOUT].count, TutorialMoves.TUTORIAL_SCOUTS)
	TutorialMoves.follow_step(turn, Id.EXPLORE)
	assert_eq(turn.player.pending_explorations.size(), 1)
	TutorialMoves.follow_step(turn, Id.SOLAR_PANEL_LEVEL_2)
	TutorialMoves.follow_step(turn, Id.HQ_LEVEL_2)
	assert_eq(_level(turn, Type.SOLAR_PANEL), 2)
	var lab := _turn()
	lab.player.buildings[Type.HEADQUARTERS].level = 3
	TutorialMoves.follow_step(lab, Id.LABORATORY_AND_RESEARCH)
	assert_eq(_level(lab, Type.LABORATORY), 1)
	assert_true(lab.player.tech_branches[TechBranch.Value.RESOURCES].unlocked)
	var scouted := _turn()
	scouted.player.buildings[Type.BARRACKS].level = 1
	scouted.player.units_on_level(1)[UnitType.Value.SCOUT].count = 2
	TutorialMoves.follow_step(scouted, Id.BARRACKS_AND_SCOUTS)
	assert_eq(scouted.player.units_on_level(1)[UnitType.Value.SCOUT].count, 2)


func test_the_harpoonists_the_guide_advises_are_recruited() -> void:
	var turn := _turn()
	turn.player.buildings[Type.BARRACKS].level = 1
	var wave := RaidWaveFactory.from_total_noise(40, DartRandom.new(3))
	turn.player.raid_state.announce(wave, 3)
	TutorialMoves.follow_raid_advice(turn, ArmyPlanner.new())
	var needed: int = RaidDefenceAdvisor.harpoonists_for(turn.player, wave)
	assert_true(needed > 0)
	assert_eq(turn.player.units_on_level(1)[HARPOONIST].count, needed)


func test_without_barracks_or_advice_the_planner_decides() -> void:
	var locked := _turn()
	locked.player.raid_state.announce(RaidWaveFactory.from_total_noise(40, DartRandom.new(3)), 3)
	TutorialMoves.follow_raid_advice(locked, ArmyPlanner.new())
	assert_eq(locked.player.units_on_level(1)[HARPOONIST].count, 0)
	var hopeless := _turn()
	hopeless.player.buildings[Type.BARRACKS].level = 1
	var wave := MonsterLair.new(MonsterDifficulty.Value.HARD, 40, MonsterFamily.Value.COLOSSUS)
	hopeless.player.raid_state.announce(wave, 3)
	assert_null(RaidDefenceAdvisor.harpoonists_for(hopeless.player, wave))
	TutorialMoves.follow_raid_advice(hopeless, ArmyPlanner.new())
	assert_true(hopeless.player.units_on_level(1)[HARPOONIST].count > 0)
