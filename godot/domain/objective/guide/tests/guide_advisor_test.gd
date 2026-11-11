extends TestCase
## test/domain/objective/guide/guide_advisor_test.dart: the guide stays
## silent, each objective of the tutorial teaches its lesson, and the halo
## points at what to touch. The group of a test per objective is one test
## walking them.

const Id := ObjectiveId.Value
const Building_ := BuildingType.Value


func _target_on(id: Id, set_up := Callable()) -> GuideTarget:
	var game := GuideSamples.guide_game(id)
	if set_up.is_valid():
		set_up.call(game.human_player())
	return GuideSamples.advice_of(game).target


func _expect(actual: GuideTarget, expected: GuideTarget) -> void:
	assert_true(actual.equals(expected), str(actual))


func test_the_guide_stays_silent_when_the_tutorial_is_off() -> void:
	assert_null(GuideSamples.advice_of(GuideSamples.guide_game(Id.HQ_LEVEL_1, false)))


func test_the_guide_stays_silent_once_the_tutorial_chapter_is_done() -> void:
	assert_null(GuideSamples.advice_of(GuideSamples.guide_game(Id.TAKE_LAIR)))


func test_each_objective_of_the_tutorial_teaches_its_lesson() -> void:
	for objective: Objective in InstallationObjectives.installation_objectives():
		var message := GuideSamples.advice_of(GuideSamples.guide_game(objective.id)).message
		assert_true(message.equals(GuideLesson.new(objective.id)), str(objective.id))


func test_the_halo_points_at_a_building_to_raise() -> void:
	_expect(_target_on(Id.HQ_LEVEL_1), GuideTarget.for_building(Building_.HEADQUARTERS))
	_expect(_target_on(Id.ALGAE_FARM), GuideTarget.for_building(Building_.ALGAE_FARM))
	_expect(_target_on(Id.SOLAR_PANEL), GuideTarget.for_building(Building_.SOLAR_PANEL))
	_expect(_target_on(Id.HQ_LEVEL_2), GuideTarget.for_building(Building_.HEADQUARTERS))


func test_the_halo_points_at_the_mine_first_then_the_extractor() -> void:
	_expect(_target_on(Id.MINES), GuideTarget.for_building(Building_.CORAL_MINE))
	_expect(
		_target_on(Id.MINES, func(p: Player) -> void: ObjectiveSamples.set_building(p, Building_.CORAL_MINE, 1)),
		GuideTarget.for_building(Building_.ORE_EXTRACTOR)
	)


func test_the_halo_points_at_the_barracks_first_then_the_scouts() -> void:
	_expect(_target_on(Id.BARRACKS_AND_SCOUTS), GuideTarget.for_building(Building_.BARRACKS))
	_expect(
		_target_on(Id.BARRACKS_AND_SCOUTS, func(p: Player) -> void:
			ObjectiveSamples.set_building(p, Building_.BARRACKS, 1)),
		GuideTarget.for_unit(UnitType.Value.SCOUT)
	)


func test_the_halo_points_at_the_map_to_explore() -> void:
	_expect(_target_on(Id.EXPLORE), GuideTarget.for_map())


func test_the_halo_points_at_the_laboratory_then_a_branch_then_its_first_research() -> void:
	_expect(_target_on(Id.LABORATORY_AND_RESEARCH), GuideTarget.for_building(Building_.LABORATORY))
	var lab := func(p: Player) -> void: ObjectiveSamples.set_building(p, Building_.LABORATORY, 1)
	var all: Dictionary[TechBranch.Value, bool] = {}
	for branch: TechBranch.Value in TechBranch.Value.values():
		all[branch] = true
	_expect(_target_on(Id.LABORATORY_AND_RESEARCH, lab), GuideTarget.for_unlock(all))
	var military: Dictionary[TechBranch.Value, bool] = {TechBranch.Value.MILITARY: true}
	_expect(
		_target_on(Id.LABORATORY_AND_RESEARCH, func(p: Player) -> void:
			lab.call(p)
			p.tech_branches[TechBranch.Value.MILITARY].unlocked = true),
		GuideTarget.for_research(military)
	)


func test_the_halo_points_at_the_harpoonists_against_the_first_raid() -> void:
	_expect(_target_on(Id.FIRST_RAID), GuideTarget.for_unit(UnitType.Value.HARPOONIST))


## Not in the Dart file: every objective done, the guide has nothing left.
func test_the_guide_stays_silent_once_every_objective_is_done() -> void:
	var game := GuideSamples.guide_game(Id.HQ_LEVEL_1)
	var all: Array[ObjectiveId.Value] = []
	for objective: Objective in ObjectiveCatalog.all():
		all.append(objective.id)
	game.human_player().saved_objective_state = ObjectiveState.new(all, true)
	assert_null(GuideSamples.advice_of(game))
