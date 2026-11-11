extends TestCase
## test/domain/objective/guide/guide_campaign_descent_test.dart: the deeper
## assaults need the admiral down there.

const Id := ObjectiveId.Value
const CHEMINEE := AssaultTarget.Value.CHEMINEE
const KERNEL := AssaultTarget.Value.KERNEL
const CHIMNEY := TransitionBaseType.Value.CHEMINEE
const ADMIRAL := UnitType.Value.ABYSS_ADMIRAL
const HARPOONIST := UnitType.Value.HARPOONIST


func _expect(game: Game, expected: GuideAdvice) -> void:
	var advice := GuideSamples.advice_of(game)
	assert_true(advice != null and advice.equals(expected), str(advice))


func test_an_admiral_on_level_1_goes_down_by_the_faille() -> void:
	var game := GuideSamples.campaign_game(Id.TAKE_CHEMINEE)
	RaidSamples.set_units(game.human_player(), ADMIRAL, 1)
	RaidSamples.set_units(game.human_player(), HARPOONIST, 3, 2)
	GuideSamples.place_post(game, 1, 7, 5, TransitionBaseType.Value.FAILLE, true)
	_expect(game, GuideAdvice.new(
		GuideAdmiralToSend.new(CHEMINEE, 2, 1), GuideTarget.for_cell(1, GridPosition.new(7, 5))))


func test_with_no_post_held_to_go_down_by_the_map() -> void:
	var game := GuideSamples.campaign_game(Id.TAKE_CHEMINEE)
	RaidSamples.set_units(game.human_player(), ADMIRAL, 1)
	assert_true(GuideSamples.advice_of(game).target.equals(GuideTarget.for_map()))


func test_an_admiral_already_deeper_does_not_count() -> void:
	var game := GuideSamples.campaign_game(Id.TAKE_CHEMINEE)
	RaidSamples.set_units(game.human_player(), ADMIRAL, 1, 3)
	assert_true(GuideSamples.advice_of(game).message is GuideAdmiralNeedsBarracks)


func test_explains_a_fallen_admiral_on_the_cheminee() -> void:
	var game := GuideSamples.campaign_game(Id.TAKE_CHEMINEE)
	RaidSamples.set_units(game.human_player(), ADMIRAL, 1, 2)
	GuideSamples.record_admiral_fell(game, "cheminee:1", game.turn)
	assert_true(GuideSamples.advice_of(game).message.equals(GuideAdmiralFell.new(CHEMINEE)))


func test_the_cheminee_in_sight_on_level_2() -> void:
	var game := GuideSamples.campaign_game(Id.TAKE_CHEMINEE)
	RaidSamples.set_units(game.human_player(), ADMIRAL, 1, 2)
	GuideSamples.place_post(game, 2, 3, 3, CHIMNEY)
	var army: Dictionary[UnitType.Value, int] = {ADMIRAL: 1}
	var plan := AssaultPlan.of(game.human_player(), 2, CHEMINEE, army)
	_expect(game, GuideAdvice.new(GuidePostAssault.new(CHEMINEE, plan.suggested_harpoonists()),
		GuideTarget.for_cell(2, GridPosition.new(3, 3))))


func test_an_admiral_on_level_2_goes_down_by_the_cheminee() -> void:
	var game := GuideSamples.campaign_game(Id.TAKE_KERNEL)
	RaidSamples.set_units(game.human_player(), ADMIRAL, 1, 2)
	RaidSamples.set_units(game.human_player(), HARPOONIST, 3, 3)
	GuideSamples.place_post(game, 2, 3, 3, CHIMNEY, true)
	_expect(game, GuideAdvice.new(
		GuideAdmiralToSend.new(KERNEL, 3, 2), GuideTarget.for_cell(2, GridPosition.new(3, 3))))


func test_an_admiral_on_level_1_first_goes_down_by_the_faille() -> void:
	var game := GuideSamples.campaign_game(Id.TAKE_KERNEL)
	RaidSamples.set_units(game.human_player(), ADMIRAL, 1)
	GuideSamples.place_post(game, 1, 7, 5, TransitionBaseType.Value.FAILLE, true)
	_expect(game, GuideAdvice.new(
		GuideAdmiralToSend.new(KERNEL, 3, 1), GuideTarget.for_cell(1, GridPosition.new(7, 5))))


func test_the_kernel_in_sight_on_level_3() -> void:
	var game := GuideSamples.campaign_game(Id.TAKE_KERNEL)
	RaidSamples.set_units(game.human_player(), ADMIRAL, 1, 3)
	GuideSamples.place_kernel(game, 4, 4)
	var advice := GuideSamples.advice_of(game)
	assert_true(advice.message is GuidePostAssault)
	var message: GuidePostAssault = advice.message
	assert_eq(message.target, KERNEL)
	assert_true(advice.target.equals(GuideTarget.for_cell(3, GridPosition.new(4, 4))))
