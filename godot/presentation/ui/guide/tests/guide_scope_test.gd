extends UiTestCase
## The inherited widget of lib/.../guide_scope.dart, and the halo that follows
## it (guide_halo_test.dart: a halo surrounds what the guide points at).

var _hits := 0


func _end_turn_target(target: GuideTarget) -> bool:
	return target.end_turn


func _count_change() -> void:
	_hits += 1


func test_a_scope_without_a_game_is_silent() -> void:
	var scope := GuideScope.new()
	assert_null(scope.advice)
	assert_null(scope.target())
	assert_false(scope.points(_end_turn_target))


func test_a_scope_reads_the_advice_of_the_tutorial() -> void:
	var game := GuideSamples.guide_game(ObjectiveId.Value.MINES)
	game.turn = 4
	var scope := GuideScope.new(game)
	assert_true(scope.advice.message.equals(GuideLesson.new(ObjectiveId.Value.MINES)))
	assert_eq(scope.turn, 4)
	assert_true(scope.target().is_building(BuildingType.Value.CORAL_MINE))
	assert_true(scope.points(func(target: GuideTarget) -> bool: return target.is_building(BuildingType.Value.CORAL_MINE)))
	assert_false(scope.points(_end_turn_target))


func test_a_scope_is_silent_once_the_tutorial_is_off() -> void:
	var scope := GuideScope.new(GuideSamples.guide_game(ObjectiveId.Value.MINES, false))
	assert_null(scope.target())


func test_it_reads_again_and_tells_it() -> void:
	var game := GuideSamples.guide_game(ObjectiveId.Value.MINES)
	var scope := GuideScope.new(game)
	scope.changed.connect(_count_change)
	game.human_player().saved_objective_state.tutorial_enabled = false
	scope.refresh()
	assert_eq(_hits, 1)
	assert_null(scope.advice)
	scope.refresh(null)
	assert_eq(_hits, 2)


func test_a_guided_halo_follows_the_target() -> void:
	var scope := GuideScope.new(GuideSamples.guide_game(ObjectiveId.Value.MINES))
	var halo := mount(GuidedHalo.new(Button.new(), scope, _end_turn_target)) as GuidedHalo
	assert_false(halo.active)
	scope.advice = GuideAdvice.new(GuideGoalMet.new(), GuideTarget.for_end_turn())
	scope.changed.emit()
	assert_true(halo.active)
	scope.advice = null
	halo.follow()
	assert_false(halo.active)


func test_a_halo_without_a_scope_is_never_lit() -> void:
	var halo := mount(GuidedHalo.new(Button.new(), null, _end_turn_target)) as GuidedHalo
	assert_false(halo.active)


func test_a_card_halo_follows_the_corners_of_the_card() -> void:
	var halo := mount(GuideCardHalo.new(PanelContainer.new(), GuideScope.new(), _end_turn_target)) as GuideCardHalo
	assert_eq(halo.radius, AbyssCardTheme.card().corner_radius_top_left)
	assert_false(halo.active)
