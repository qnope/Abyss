extends TestCase
## Not in the Dart files: the halo of each objective of the tutorial
## (GuideTargets) and the end of the turn when the worksite or the
## recruitment it asks for is taken (GuideBusy). The Dart tests read both
## through GuideAdvisor (guide_advisor_test.dart, ported too,
## "the halo points at what to touch"); the values are what a scratch Dart
## script printed.

const Id := ObjectiveId.Value
const Type := BuildingType.Value


func test_each_objective_of_the_tutorial_has_its_halo_none_past_it() -> void:
	var got: Array[String] = []
	for objective: Objective in InstallationObjectives.installation_objectives():
		var player := ObjectiveSamples.objective_game().human_player()
		got.append("%s %s" % [DartEnum.name_of(Id, objective.id), GuideTargets.of(player, objective.id)])
	assert_eq(got, [
		"hqLevel1 GuideTarget(base, headquarters)",
		"algaeFarm GuideTarget(base, algaeFarm)",
		"mines GuideTarget(base, coralMine)",
		"solarPanel GuideTarget(base, solarPanel)",
		"hqLevel2 GuideTarget(base, headquarters)",
		"barracksAndScouts GuideTarget(base, barracks)",
		"explore GuideTarget(map, ())",
		"solarPanelLevel2 GuideTarget(base, solarPanel)",
		"laboratoryAndResearch GuideTarget(base, laboratory)",
		"firstRaid GuideTarget(army, harpoonist)",
	] as Array[String])
	assert_null(GuideTargets.of(ObjectiveSamples.objective_game().human_player(), Id.TAKE_LAIR))


func test_the_halo_moves_on_once_the_first_building_stands() -> void:
	var player := ObjectiveSamples.objective_game().human_player()
	for type: Type in [Type.CORAL_MINE, Type.BARRACKS, Type.LABORATORY]:
		ObjectiveSamples.set_building(player, type, 1)
	assert_eq(str(GuideTargets.of(player, Id.MINES)), "GuideTarget(base, oreExtractor)")
	assert_eq(str(GuideTargets.of(player, Id.BARRACKS_AND_SCOUTS)), "GuideTarget(army, scout)")
	var research := GuideTargets.of(player, Id.LABORATORY_AND_RESEARCH)
	assert_eq(str(research), "GuideTarget(research, (military, resources, explorer))")
	assert_true(research.is_branch(TechBranch.Value.RESOURCES))
	assert_false(research.is_tech_node(TechBranch.Value.RESOURCES, 0))
	player.tech_branches[TechBranch.Value.MILITARY].unlocked = true
	player.tech_branches[TechBranch.Value.EXPLORER].unlocked = true
	research = GuideTargets.of(player, Id.LABORATORY_AND_RESEARCH)
	assert_eq(str(research), "GuideTarget(research, (military, explorer))")
	assert_true(research.is_tech_node(TechBranch.Value.EXPLORER, 1))


func test_busy_once_the_worksite_or_the_recruitment_of_the_turn_is_taken() -> void:
	var player := ObjectiveSamples.objective_game().human_player()
	var farm := GuideTarget.for_building(Type.ALGAE_FARM)
	var scout := GuideTarget.for_unit(UnitType.Value.SCOUT)
	assert_null(GuideBusy.of(player, farm))
	assert_null(GuideBusy.of(player, scout))
	assert_null(GuideBusy.of(player, GuideTarget.for_map()))
	player.worksite.upgrades = 1
	player.recruited_unit_types.append(UnitType.Value.SCOUT)
	assert_eq(str(GuideBusy.of(player, farm)), "GuideAdvice(GuideWorksiteTaken[], GuideTarget(endTurn, ()))")
	assert_eq(str(GuideBusy.of(player, scout)), "GuideAdvice(GuideAlreadyRecruited[], GuideTarget(endTurn, ()))")
	assert_null(GuideBusy.of(player, GuideTarget.for_map()))
	ObjectiveSamples.set_building(player, Type.HEADQUARTERS, 5)
	assert_null(GuideBusy.of(player, farm))
	player.buildings.erase(Type.HEADQUARTERS)
	assert_eq(str(GuideBusy.of(player, farm)), "GuideAdvice(GuideWorksiteTaken[], GuideTarget(endTurn, ()))")
