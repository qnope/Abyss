extends TestCase
## test/domain/objective/guide/guide_campaign_alerts_test.dart: the alerts
## of GuideAlerts before the step: a post nobody defends, an announced
## kraken wave.

const Id := ObjectiveId.Value
const MODULE := BuildingType.Value.DESCENT_MODULE


## A game on `id` whose Faille at (7, 5) is held with its Module built.
static func _held_faille(id: Id) -> Game:
	var game := GuideSamples.campaign_game(id)
	ObjectiveSamples.set_building(game.human_player(), MODULE, 1)
	GuideSamples.place_post(game, 1, 7, 5, TransitionBaseType.Value.FAILLE, true)
	return game


## A game on `id` whose kernel at (4, 4) is held, `wave` announced.
static func _wave_on(id: Id, wave: MonsterLair) -> Game:
	var game := GuideSamples.campaign_game(id)
	GuideSamples.place_kernel(game, 4, 4, true)
	game.human_player().volcano_state.announce(wave, game.turn)
	return game


static func _first_wave() -> MonsterLair:
	return VolcanoWaveFactory.from_kernel_level(0, 100, true)


func _message(game: Game) -> GuideMessage:
	return GuideSamples.advice_of(game).message


func test_a_post_nobody_defends_comes_first_once_its_passage_is_built() -> void:
	var advice := GuideSamples.advice_of(_held_faille(Id.HQ_LEVEL_8))
	var expected := GuideAdvice.new(GuidePostUndefended.new(TransitionBaseType.Value.FAILLE, 2),
		GuideTarget.for_cell(1, GridPosition.new(7, 5)))
	assert_true(advice.equals(expected), str(advice))


func test_a_post_nobody_defends_is_forgotten_once_a_unit_stands_below() -> void:
	var game := _held_faille(Id.HQ_LEVEL_8)
	RaidSamples.set_units(game.human_player(), UnitType.Value.SCOUT, 1, 2)
	assert_true(_message(game).equals(GuideLesson.new(Id.HQ_LEVEL_8)), str(_message(game)))


func test_a_post_nobody_defends_waits_for_the_passage_to_be_built() -> void:
	var game := _held_faille(Id.HQ_LEVEL_8)
	ObjectiveSamples.set_building(game.human_player(), MODULE, 0)
	assert_true(_message(game).equals(GuideLesson.new(Id.HQ_LEVEL_8)), str(_message(game)))


func test_a_post_nobody_defends_leaves_the_descent_onto_its_level_to_its_own_lesson() -> void:
	var message := _message(_held_faille(Id.DESCEND_LEVEL_2))
	assert_true(message.equals(GuideLesson.new(Id.DESCEND_LEVEL_2)), str(message))


func test_an_announced_kraken_wave_asks_for_a_garrison_large_enough() -> void:
	var game := _wave_on(Id.KERNEL_LEVEL_1, _first_wave())
	var needed: Variant = KernelDefenceAdvisor.units_for(game.human_player(), _first_wave())
	assert_not_null(needed)
	var count: int = needed
	assert_true(count > 0)
	var advice := GuideSamples.advice_of(game)
	var expected := GuideAdvice.new(GuideKernelWave.new(_first_wave().total_count(), needed),
		GuideTarget.for_garrison(3, GridPosition.new(4, 4)))
	assert_true(advice.equals(expected), str(advice))


func test_an_announced_kraken_wave_says_nothing_of_a_garrison_that_holds() -> void:
	var game := _wave_on(Id.KERNEL_LEVEL_1, _first_wave())
	RaidSamples.set_units(game.human_player(), UnitType.Value.DOME_BREAKER, 40, KernelGarrison.STOCK_KEY)
	assert_true(_message(game).equals(GuideLesson.new(Id.KERNEL_LEVEL_1)), str(_message(game)))


func test_an_announced_kraken_wave_names_no_number_when_none_would_hold_even_past_chapter_5() -> void:
	var flood := MonsterLair.new(MonsterDifficulty.Value.HARD, 2000, MonsterFamily.Value.KRAKEN)
	var game := _wave_on(Id.KERNEL_LEVEL_5, flood)
	assert_true(_message(game).equals(GuideKernelWave.new(2000)), str(_message(game)))


func test_an_announced_kraken_wave_comes_before_a_post_nobody_defends() -> void:
	var game := _wave_on(Id.KERNEL_LEVEL_1, _first_wave())
	ObjectiveSamples.set_building(game.human_player(), MODULE, 1)
	GuideSamples.place_post(game, 1, 7, 5, TransitionBaseType.Value.FAILLE, true)
	assert_true(_message(game) is GuideKernelWave)



## Not in the Dart file: a wave announced while the kernel is held by
## nobody raises no alert.
func test_an_announced_kraken_wave_without_a_held_kernel_says_nothing() -> void:
	var game := GuideSamples.campaign_game(Id.KERNEL_LEVEL_1)
	GuideSamples.place_kernel(game, 4, 4)
	game.human_player().volcano_state.announce(_first_wave(), game.turn)
	assert_true(_message(game).equals(GuideLesson.new(Id.KERNEL_LEVEL_1)), str(_message(game)))
