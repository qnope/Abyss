extends TestCase
## test/domain/objective/guide/guide_campaign_assault_test.dart: the guide
## on the objective of taking a Faille, step by step.

const Id := ObjectiveId.Value
const FAILLE := AssaultTarget.Value.FAILLE
const ADMIRAL := UnitType.Value.ABYSS_ADMIRAL


## The harpoonists the plan advises with the admirals and guardians of the
## human player of `game` on `level`.
static func _advised(game: Game, target: AssaultTarget.Value, level: int) -> Variant:
	var units := game.human_player().units_on_level(level)
	var army: Dictionary[UnitType.Value, int] = {
		ADMIRAL: Unit.count_in(units, ADMIRAL), UnitType.Value.GUARDIAN: Unit.count_in(units, UnitType.Value.GUARDIAN),
	}
	return AssaultPlan.of(game.human_player(), level, target, army).suggested_harpoonists()


func _expect(game: Game, expected: GuideAdvice) -> void:
	var advice := GuideSamples.advice_of(game)
	assert_true(advice != null and advice.equals(expected), str(advice))


func _post(game: Game, x: int, y: int, hidden := false) -> void:
	GuideSamples.place_post(game, 1, x, y, TransitionBaseType.Value.FAILLE, false, hidden)


func test_the_guide_stays_silent_on_the_campaign_when_the_tutorial_is_off() -> void:
	assert_null(GuideSamples.advice_of(GuideSamples.campaign_game(Id.TAKE_FAILLE, false)))


func test_taking_a_faille_asks_for_the_barracks_the_admiral_needs() -> void:
	_expect(GuideSamples.campaign_game(Id.TAKE_FAILLE), GuideAdvice.new(
		GuideAdmiralNeedsBarracks.new(FAILLE, 2), GuideTarget.for_building(BuildingType.Value.BARRACKS)))


func test_taking_a_faille_then_asks_to_recruit_the_admiral() -> void:
	var game := GuideSamples.campaign_game(Id.TAKE_FAILLE)
	ObjectiveSamples.set_building(game.human_player(), BuildingType.Value.BARRACKS, 2)
	_expect(game, GuideAdvice.new(GuideAdmiralToRecruit.new(FAILLE), GuideTarget.for_unit(ADMIRAL)))


func test_taking_a_faille_then_sends_exploring_while_no_faille_is_in_sight() -> void:
	var game := GuideSamples.campaign_game(Id.TAKE_FAILLE)
	RaidSamples.set_units(game.human_player(), ADMIRAL, 1)
	_post(game, 0, 0, true)
	_expect(game, GuideAdvice.new(GuidePostToFind.new(FAILLE), GuideTarget.for_map()))


func test_taking_a_faille_then_points_at_the_nearest_faille_in_sight_with_the_army() -> void:
	var game := GuideSamples.campaign_game(Id.TAKE_FAILLE)
	RaidSamples.set_units(game.human_player(), ADMIRAL, 1)
	RaidSamples.set_units(game.human_player(), UnitType.Value.GUARDIAN, 2)
	game.human_player().revealed_cells_per_level[1].clear()
	_post(game, 9, 9)
	_post(game, 7, 5)
	_post(game, 5, 6, true)
	var harpoonists: Variant = _advised(game, FAILLE, 1)
	assert_not_null(harpoonists)
	_expect(game, GuideAdvice.new(
		GuidePostAssault.new(FAILLE, harpoonists), GuideTarget.for_cell(1, GridPosition.new(7, 5))))


func test_taking_a_faille_explains_a_victory_where_the_admiral_fell_this_turn_only() -> void:
	var game := GuideSamples.campaign_game(Id.TAKE_FAILLE)
	RaidSamples.set_units(game.human_player(), ADMIRAL, 1)
	_post(game, 7, 5)
	GuideSamples.record_admiral_fell(game, "faille:0", game.turn)
	var advice := GuideSamples.advice_of(game)
	assert_true(advice.message.equals(GuideAdmiralFell.new(FAILLE)), str(advice.message))
	assert_true(advice.target.equals(GuideTarget.for_cell(1, GridPosition.new(7, 5))), str(advice.target))
	game.turn += 1
	assert_true(GuideSamples.advice_of(game).message is GuidePostAssault)


func test_taking_a_faille_ignores_a_fallen_admiral_on_another_target() -> void:
	var game := GuideSamples.campaign_game(Id.TAKE_FAILLE)
	for name: String in ["volcanicKernel", "cheminee:0", "Base A"]:
		GuideSamples.record_admiral_fell(game, name, game.turn)
	assert_true(GuideSamples.advice_of(game).message is GuideAdmiralNeedsBarracks)


func test_taking_a_faille_breaks_a_tie_of_distance_by_row_then_by_column() -> void:
	var game := GuideSamples.campaign_game(Id.TAKE_FAILLE)
	RaidSamples.set_units(game.human_player(), ADMIRAL, 1)
	_post(game, 5, 7)
	_post(game, 7, 5)
	_post(game, 3, 5)
	var target := GuideSamples.advice_of(game).target
	assert_true(target.equals(GuideTarget.for_cell(1, GridPosition.new(3, 5))), str(target))
	_post(game, 5, 3)
	target = GuideSamples.advice_of(game).target
	assert_true(target.equals(GuideTarget.for_cell(1, GridPosition.new(5, 3))), str(target))
