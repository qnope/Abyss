extends UiTestCase
## test/presentation/widgets/save/save_card_test.dart.

var _opened := 0
var _deleted := 0


func test_shows_a_game_in_progress() -> void:
	var card := _card(_summary(SaveOutcome.Value.IN_PROGRESS))
	assert_eq(texts(card), PackedStringArray(
		["PR", "Alice", "NORMAL", "il y a 2 h", "Tour 14 · Profondeurs · QG niv. 3", "412", "298", "186", "74", "9"]))
	assert_eq(card.thumbnail.modulate.a, 1.0)
	assert_eq(card.details.pill.label.get_theme_color(&"font_color"), DifficultyTexts.color(Difficulty.Value.NORMAL))
	assert_no_raw_keys()


func test_lists_the_five_resources_with_their_icons() -> void:
	var card := _card(_summary(SaveOutcome.Value.IN_PROGRESS))
	assert_eq(find_type("TextureRect", card.details.strip).size(), 5)
	assert_true(card.details.strip.visible)
	assert_false(card.details.footnote_label.visible)


func test_a_won_game_shows_its_badge_and_conquest() -> void:
	var summary := _summary(SaveOutcome.Value.VICTORY)
	summary.volcanic_kernel_captured = true
	summary.last_played_at = SavedGameSamples.now() - 5 * 86400000
	var card := _card(summary)
	assert_not_null(find_text("★ VICTOIRE"))
	assert_not_null(find_text("Noyau Volcanique conquis"))
	assert_not_null(find_text("5 oct."))
	assert_false(card.details.strip.visible)


func test_a_game_in_free_play_shows_its_victory_and_its_resources() -> void:
	var card := _card(_summary(SaveOutcome.Value.FREE_PLAY))
	assert_not_null(find_text("★ VICTOIRE"))
	assert_not_null(find_text("Tour 14 · Profondeurs · QG niv. 3"))
	assert_true(card.details.strip.visible)


func test_a_lost_game_is_greyed_out() -> void:
	var card := _card(_summary(SaveOutcome.Value.DEFEAT))
	assert_not_null(find_text("DÉFAITE"))
	assert_not_null(find_text("Voir le bilan de la partie"))
	assert_eq(card.panel.theme_type_variation, &"SavePanelFaded")
	assert_almost_eq(card.thumbnail.modulate.a, AbyssColors.UNAVAILABLE_OPACITY, 1e-6)
	assert_eq(card.details.name_label.get_theme_color(&"font_color"), AbyssColors.ON_SURFACE_DIM)
	assert_eq(card.details.meta_label.get_theme_color(&"font_color"), AbyssColors.ON_SURFACE_DIM)
	assert_eq(card.details.footnote_label.get_theme_color(&"font_color"),
		AbyssColors.dimmed(AbyssColors.ON_SURFACE_DIM))


func test_glows_when_highlighted_only() -> void:
	assert_eq(_card(_summary(SaveOutcome.Value.IN_PROGRESS)).panel.theme_type_variation, &"SavePanel")
	var lit := _card(_summary(SaveOutcome.Value.IN_PROGRESS), true)
	assert_eq(lit.panel.theme_type_variation, &"SavePanelHighlighted")


func test_pictures_the_depth_reached_with_its_initials() -> void:
	var card := _card(_summary(SaveOutcome.Value.IN_PROGRESS))
	assert_eq(card.thumbnail.custom_minimum_size, Vector2(76.0, 76.0))
	assert_eq(card.thumbnail.initials_label.text, "PR")
	use_language("en")
	assert_eq(card.thumbnail.initials_label.text, "DE")


func test_a_touch_on_the_card_opens_the_game() -> void:
	var card := _card(_summary(SaveOutcome.Value.IN_PROGRESS))
	press(card.tap_button)
	assert_eq(_opened, 1)
	assert_eq(_deleted, 0)


func test_the_options_delete_without_opening_the_game() -> void:
	var card := _card(_summary(SaveOutcome.Value.IN_PROGRESS))
	card.menu.popup.id_pressed.emit(SaveCardMenu.DELETE_ID)
	assert_eq(_deleted, 1)
	assert_eq(_opened, 0)
	assert_eq(card.menu.size_flags_horizontal, Control.SIZE_SHRINK_END)
	assert_eq(card.menu.get_index(), card.tap_button.get_index() + 1, "the options are over the touch area")


func test_follows_the_language() -> void:
	var card := _card(_summary(SaveOutcome.Value.DEFEAT))
	use_language("en")
	assert_not_null(find_text("DEFEAT"))
	assert_not_null(find_text("2 h ago"))
	assert_no_raw_keys()


func _summary(outcome: SaveOutcome.Value) -> SaveSummary:
	var resources: Dictionary[ResourceType.Value, int] = {
		ResourceType.Value.ALGAE: 412, ResourceType.Value.CORAL: 298, ResourceType.Value.ORE: 186,
		ResourceType.Value.ENERGY: 74, ResourceType.Value.PEARL: 9,
	}
	return SaveSummary.new("Alice", 14, Difficulty.Value.NORMAL, outcome, 2, 3, resources,
		SavedGameSamples.now() - 2 * SavedGameSamples.HOUR)


func _card(summary: SaveSummary, highlighted := false) -> SaveCard:
	var card := mount(SaveCard.new(summary, SavedGameSamples.now(), highlighted)) as SaveCard
	card.tapped.connect(func() -> void: _opened += 1)
	card.delete_requested.connect(func() -> void: _deleted += 1)
	return card
