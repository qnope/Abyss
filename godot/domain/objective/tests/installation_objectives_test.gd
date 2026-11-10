extends TestCase
## test/domain/objective/installation_objectives_test.dart: the ten
## objectives of the tutorial and how far a player is on each.

const Id := ObjectiveId.Value
const Type := BuildingType.Value
const SCOUT := UnitType.Value.SCOUT


func test_installation_objectives_hq_level_1_qg_au_niveau_1() -> void:
	var game := ObjectiveSamples.objective_game()
	_expect(game, Id.HQ_LEVEL_1, 0, 1)
	ObjectiveSamples.set_building(game.human_player(), Type.HEADQUARTERS, 1)
	_expect(game, Id.HQ_LEVEL_1, 1, 1)


func test_installation_objectives_algae_farm_ferme_d_algues_construite() -> void:
	var game := ObjectiveSamples.objective_game()
	_expect(game, Id.ALGAE_FARM, 0, 1)
	ObjectiveSamples.set_building(game.human_player(), Type.ALGAE_FARM, 1)
	_expect(game, Id.ALGAE_FARM, 1, 1)


func test_installation_objectives_mines_mine_de_corail_et_extracteur_compte_sur_2() -> void:
	var game := ObjectiveSamples.objective_game()
	_expect(game, Id.MINES, 0, 2)
	ObjectiveSamples.set_building(game.human_player(), Type.ORE_EXTRACTOR, 1)
	_expect(game, Id.MINES, 1, 2)
	ObjectiveSamples.set_building(game.human_player(), Type.CORAL_MINE, 3)
	_expect(game, Id.MINES, 2, 2)


func test_installation_objectives_solar_panel_panneau_solaire_construit() -> void:
	var game := ObjectiveSamples.objective_game()
	_expect(game, Id.SOLAR_PANEL, 0, 1)
	ObjectiveSamples.set_building(game.human_player(), Type.SOLAR_PANEL, 1)
	_expect(game, Id.SOLAR_PANEL, 1, 1)


func test_installation_objectives_solar_panel_level_2_panneau_solaire_au_niveau_2() -> void:
	var game := ObjectiveSamples.objective_game()
	ObjectiveSamples.set_building(game.human_player(), Type.SOLAR_PANEL, 1)
	_expect(game, Id.SOLAR_PANEL_LEVEL_2, 1, 2)
	ObjectiveSamples.set_building(game.human_player(), Type.SOLAR_PANEL, 2)
	_expect(game, Id.SOLAR_PANEL_LEVEL_2, 2, 2)


func test_installation_objectives_solar_panel_level_2_est_donne_juste_avant_la_technologie() -> void:
	var ids: Array = []
	for objective: Objective in InstallationObjectives.installation_objectives():
		ids.append(objective.id)
	assert_eq(ids.find(Id.SOLAR_PANEL_LEVEL_2), ids.find(Id.LABORATORY_AND_RESEARCH) - 1)


func test_installation_objectives_hq_level_2_qg_au_niveau_2_progression_par_niveau() -> void:
	var game := ObjectiveSamples.objective_game()
	ObjectiveSamples.set_building(game.human_player(), Type.HEADQUARTERS, 1)
	_expect(game, Id.HQ_LEVEL_2, 1, 2)
	ObjectiveSamples.set_building(game.human_player(), Type.HEADQUARTERS, 3)
	_expect(game, Id.HQ_LEVEL_2, 2, 2)


func test_installation_objectives_barracks_and_scouts_caserne_puis_2_eclaireurs_sur_3() -> void:
	var game := ObjectiveSamples.objective_game()
	var player := game.human_player()
	_expect(game, Id.BARRACKS_AND_SCOUTS, 0, 3)
	ObjectiveSamples.set_building(player, Type.BARRACKS, 1)
	_expect(game, Id.BARRACKS_AND_SCOUTS, 1, 3)
	RaidSamples.set_units(player, SCOUT, 1)
	_expect(game, Id.BARRACKS_AND_SCOUTS, 2, 3)
	RaidSamples.set_units(player, SCOUT, 1, 2)
	_expect(game, Id.BARRACKS_AND_SCOUTS, 3, 3)
	RaidSamples.set_units(player, SCOUT, 5)
	_expect(game, Id.BARRACKS_AND_SCOUTS, 3, 3)


func test_installation_objectives_explore_une_case_revelee_hors_de_la_zone_de_depart() -> void:
	var game := ObjectiveSamples.objective_game()
	var player := game.human_player()
	player.add_revealed_cell(1, GridPosition.new(5, 5))
	_expect(game, Id.EXPLORE, 0, 1)
	player.add_revealed_cell(1, GridPosition.new(8, 5))
	_expect(game, Id.EXPLORE, 1, 1)


func test_installation_objectives_explore_done_once_a_real_exploration_is_resolved() -> void:
	var game := ObjectiveSamples.objective_game()
	game.human_player().pending_explorations.append(ExplorationOrder.new(GridPosition.new(8, 5), 1))
	_expect(game, Id.EXPLORE, 0, 1)
	ExplorationResolver.resolve(game)
	_expect(game, Id.EXPLORE, 1, 1)


func test_installation_objectives_laboratory_and_research_laboratoire_et_une_recherche_sur_2() -> void:
	var game := ObjectiveSamples.objective_game()
	var player := game.human_player()
	_expect(game, Id.LABORATORY_AND_RESEARCH, 0, 2)
	ObjectiveSamples.set_building(player, Type.LABORATORY, 1)
	_expect(game, Id.LABORATORY_AND_RESEARCH, 1, 2)
	var branch := player.tech_branches[TechBranch.Value.EXPLORER]
	branch.unlocked = true
	branch.research_level = 1
	_expect(game, Id.LABORATORY_AND_RESEARCH, 2, 2)


func test_installation_objectives_first_raid_un_raid_repousse() -> void:
	var game := ObjectiveSamples.objective_game()
	game.human_player().raid_state.record_outcome(false)
	_expect(game, Id.FIRST_RAID, 0, 1)
	game.human_player().raid_state.record_outcome(true)
	_expect(game, Id.FIRST_RAID, 1, 1)


## Not in the Dart file: the explored goal is not met without level 1.
func test_explore_is_not_met_without_the_map_of_level_1() -> void:
	var game := ObjectiveSamples.objective_game()
	game.human_player().add_revealed_cell(1, GridPosition.new(8, 5))
	game.levels = {}
	_expect(game, Id.EXPLORE, 0, 1)


func _expect(game: Game, id: Id, current: int, target: int) -> void:
	var expected := ObjectiveSamples.expected(current, target)
	assert_eq(ObjectiveSamples.progress(game, id), expected, DartEnum.name_of(Id, id))
