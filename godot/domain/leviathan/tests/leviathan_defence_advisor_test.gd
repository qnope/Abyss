extends TestCase
## test/domain/leviathan/leviathan_defence_advisor_test.dart: the defence
## of the Faille the guide advises against the guardians coming back.

const HARPOONIST := UnitType.Value.HARPOONIST


func _units_for(war: PostWar) -> Variant:
	return LeviathanDefenceAdvisor.units_for(war.game, war.human(), 2)


func test_units_for_asks_for_defenders_on_an_empty_level_2() -> void:
	var needed: Variant = _units_for(LeviathanScene.of())
	assert_not_null(needed)
	var count: int = needed
	assert_true(count > 0, str(count))


func test_units_for_the_advised_army_holds_no_more_is_asked_once_it_stands() -> void:
	var war := LeviathanScene.of()
	var needed: int = _units_for(war)
	war.put(war.human(), 2, {HARPOONIST: needed})
	assert_eq(_units_for(war), needed)


func test_units_for_counts_the_units_already_there() -> void:
	var war := LeviathanScene.of()
	war.put(war.human(), 2, {UnitType.Value.GUARDIAN: 200, HARPOONIST: 200})
	assert_eq(_units_for(war), 400)


func test_units_for_gives_the_same_answer_for_the_same_game() -> void:
	var war := LeviathanScene.of()
	war.put(war.human(), 2, {HARPOONIST: 2})
	var first: Variant = _units_for(war)
	assert_eq(_units_for(war), first)


## Not in the Dart file: the answer depends on the strength the guardians
## keep, the difficulty of the game.
func test_units_for_asks_more_against_stronger_guardians() -> void:
	var war := LeviathanScene.of()
	war.game.saved_difficulty = Difficulty.Value.EASY
	var easy: int = _units_for(war)
	war.game.saved_difficulty = Difficulty.Value.HARD
	var hard: int = _units_for(war)
	assert_true(hard > easy, "%d > %d" % [hard, easy])
	assert_eq(LeviathanDefenceAdvisor.MAX_ADDED, 150)
	var planner := LeviathanDefenceAdvisor.planner()
	assert_eq([planner.rehearsals, planner.confidence], [20, 0.95])


## Not in the Dart file: the Rempart vivant shields the base only, not the
## level below a Faille: the advice is that of the other perk of its tier.
func test_units_for_the_living_rampart_does_not_hold_the_faille() -> void:
	var answers: Array = []
	for option: TechOption.Value in [TechOption.Value.A, TechOption.Value.B]:
		var war := LeviathanScene.of()
		war.game.saved_difficulty = Difficulty.Value.EASY
		war.human().tech_branches[TechBranch.Value.MILITARY] = TechHelpers.researched_branch(
			TechBranch.Value.MILITARY, 4, [TechOption.Value.B, option] as Array[TechOption.Value]
		)
		war.put(war.human(), 2, {UnitType.Value.GUARDIAN: 5})
		answers.append(_units_for(war))
	assert_eq(answers[0], answers[1])
