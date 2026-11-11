extends TestCase
## Not in the Dart files: every message of the guide reads as Dart prints it
## (`$runtimeType$_figures`), as a scratch Dart script printed them. The
## campaign messages come from GuideCampaign, GuideAssault, GuideAlerts and
## GuideLeviathan.

const Target := AssaultTarget.Value


func test_each_message_reads_as_dart_prints_it() -> void:
	var messages: Array[GuideMessage] = [
		GuideLesson.new(ObjectiveId.Value.ALGAE_FARM),
		GuideGoalMet.new(),
		GuideWorksiteTaken.new(),
		GuideAlreadyRecruited.new(),
		GuideExploring.new(),
		GuideStorm.new(8),
		GuideWreck.new(9, true),
		GuideRaidAlert.new(12, 28, 5, 2, true),
		GuideRaidAlert.new(10, 400, null, 0, false, true),
		GuideAdmiralNeedsBarracks.new(Target.FAILLE, 4),
		GuideAdmiralToRecruit.new(Target.CHEMINEE),
		GuideAdmiralToSend.new(Target.KERNEL, 3, 1),
		GuidePostToFind.new(Target.FAILLE),
		GuidePostAssault.new(Target.CHEMINEE, 7),
		GuidePostAssault.new(Target.KERNEL),
		GuideAdmiralFell.new(Target.KERNEL),
		GuidePassageNeedsHq.new(BuildingType.Value.DESCENT_MODULE, 4),
		GuidePostUndefended.new(TransitionBaseType.Value.CHEMINEE, 3),
		GuideKernelWave.new(30, 12),
		GuideKernelWave.new(30),
		GuideLeviathanReturn.new(2, 3),
	]
	var texts: Array[String] = []
	for message: GuideMessage in messages:
		texts.append(str(message))
	assert_eq(texts, [
		"GuideLesson[ObjectiveId.algaeFarm]",
		"GuideGoalMet[]",
		"GuideWorksiteTaken[]",
		"GuideAlreadyRecruited[]",
		"GuideExploring[]",
		"GuideStorm[8]",
		"GuideWreck[9, true]",
		"GuideRaidAlert[12, 28, 5, 2, true, false]",
		"GuideRaidAlert[10, 400, -1, 0, false, true]",
		"GuideAdmiralNeedsBarracks[AssaultTarget.faille, 4]",
		"GuideAdmiralToRecruit[AssaultTarget.cheminee]",
		"GuideAdmiralToSend[AssaultTarget.kernel, 3, 1]",
		"GuidePostToFind[AssaultTarget.faille]",
		"GuidePostAssault[AssaultTarget.cheminee, 7]",
		"GuidePostAssault[AssaultTarget.kernel, -1]",
		"GuideAdmiralFell[AssaultTarget.kernel]",
		"GuidePassageNeedsHq[BuildingType.descentModule, 4]",
		"GuidePostUndefended[TransitionBaseType.cheminee, 3]",
		"GuideKernelWave[30, 12]",
		"GuideKernelWave[30, -1]",
		"GuideLeviathanReturn[2, 3]",
	] as Array[String])


func test_a_message_equals_only_a_message_of_its_kind() -> void:
	assert_false(GuideGoalMet.new().equals("GuideGoalMet[]"))
	assert_false(GuidePostToFind.new(Target.FAILLE).equals(GuideAdmiralFell.new(Target.FAILLE)))
	assert_false(GuideKernelWave.new(30).equals(GuideKernelWave.new(30, 12)))
	assert_true(GuideLeviathanReturn.new(2).equals(GuideLeviathanReturn.new(2, 0)))


func test_the_targets_read_as_dart_prints_them() -> void:
	var cell := GridPosition.new(3, 4)
	var branches: Dictionary[TechBranch.Value, bool] = {
		TechBranch.Value.MILITARY: true, TechBranch.Value.RESOURCES: true, TechBranch.Value.EXPLORER: true
	}
	assert_eq(str(GuideTarget.for_cell(2, cell)), "GuideTarget(map, GridPosition(3, 4) on 2)")
	assert_eq(str(GuideTarget.for_garrison(3, cell)), "GuideTarget(map, GridPosition(3, 4) on 3)")
	assert_eq(str(GuideTarget.for_end_turn()), "GuideTarget(endTurn, ())")
	assert_eq(str(GuideTarget.for_map()), "GuideTarget(map, ())")
	assert_eq(str(GuideTarget.for_unit(UnitType.Value.SCOUT)), "GuideTarget(army, scout)")
	assert_eq(str(GuideTarget.for_unlock(branches)), "GuideTarget(research, (military, resources, explorer))")
