extends UiTestCase
## test/presentation/widgets/guide/guide_bubble_test.dart: the guide's words
## at the bottom of the screen.

const FIRST_TEXT := "Bravo, c'est fait ! Termine le tour pour valider l'objectif et toucher ta récompense."

var _first := GuideAdvice.new(GuideGoalMet.new(), GuideTarget.for_end_turn())
var _second := GuideAdvice.new(GuideLesson.new(ObjectiveId.Value.MINES), GuideTarget.for_end_turn())
var _explore := GuideAdvice.new(GuidePostToFind.new(AssaultTarget.Value.FAILLE), GuideTarget.for_map())


func _bubble(advice: GuideAdvice, turn := 1) -> GuideBubble:
	var bubble := mount(GuideBubble.new()) as GuideBubble
	bubble.show_advice(advice, turn)
	return bubble


func test_shows_nothing_without_advice() -> void:
	assert_false(_bubble(null).visible)


func test_shows_the_portrait_of_the_guide_its_advice_and_got_it() -> void:
	var bubble := _bubble(_first)
	assert_true(bubble.visible)
	assert_not_null(find_text(FIRST_TEXT))
	assert_not_null(find_text("Compris"))
	assert_eq(bubble.portrait.icon_path, GuideBubble.PORTRAIT)
	assert_eq(bubble.portrait.custom_minimum_size, Vector2(64, 64))
	assert_eq(bubble.panel.theme_type_variation, AbyssGuideTheme.BUBBLE)


func test_got_it_hides_it_until_the_advice_changes() -> void:
	var bubble := _bubble(_first)
	press("Compris")
	assert_false(bubble.visible)
	bubble.show_advice(_first, 1)
	assert_false(bubble.visible)
	bubble.show_advice(_second, 1)
	assert_true(bubble.visible)
	assert_true(bubble.message_label.text.begins_with("Le corail et le minerai paient presque tout."))
	bubble.show_advice(_first, 1)
	assert_true(bubble.visible)


func test_it_speaks_english_and_spanish() -> void:
	var bubble := _bubble(_first)
	use_language("en")
	assert_eq(bubble.message_label.text, "Well done, that's it! End the turn to complete the objective and collect your reward.")
	assert_eq(bubble.got_it.text, "Got it")
	use_language("es")
	assert_eq(bubble.got_it.text, "Entendido")
	assert_no_raw_keys(bubble)


func test_an_exploration_comes_back_after_got_it_on_the_next_turn() -> void:
	var bubble := _bubble(_explore, 3)
	press("Compris")
	assert_false(bubble.visible)
	bubble.show_advice(_explore, 3)
	assert_false(bubble.visible)
	bubble.show_advice(_explore, 4)
	assert_true(bubble.visible)


func test_any_other_advice_stays_hidden_on_the_next_turn() -> void:
	var bubble := _bubble(_first, 3)
	press("Compris")
	bubble.show_advice(_first, 4)
	assert_false(bubble.visible)


func test_it_follows_the_scope_it_is_given() -> void:
	var game := GuideSamples.guide_game(ObjectiveId.Value.MINES)
	var scope := GuideScope.new(game)
	var bubble := mount(GuideBubble.new(scope)) as GuideBubble
	assert_true(bubble.visible)
	press("Compris")
	game.human_player().saved_objective_state.tutorial_enabled = false
	scope.refresh()
	assert_false(bubble.visible)
	game.human_player().saved_objective_state.tutorial_enabled = true
	scope.refresh()
	assert_true(bubble.visible, "a new advice speaks again")
