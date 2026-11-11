extends TextsTestCase
## test/presentation/extensions/save_summary_extensions_test.dart.


func test_a_game_in_progress_is_badged_with_its_difficulty() -> void:
	var summary := _summary(SaveOutcome.Value.IN_PROGRESS, Difficulty.Value.EASY)
	assert_eq(SaveSummaryTexts.badge_label(summary), "FACILE")
	assert_eq(SaveSummaryTexts.badge_color(summary), AbyssColors.SUCCESS)
	assert_eq(SaveSummaryTexts.meta_line(summary), "Tour 14 · Profondeurs · QG niv. 3")
	assert_null(SaveSummaryTexts.footnote(summary))
	assert_eq(SaveSummaryTexts.depth_name(summary), "Profondeurs")


func test_a_won_game_is_badged_in_gold_with_its_difficulty() -> void:
	var summary := _summary(SaveOutcome.Value.VICTORY, Difficulty.Value.EASY, 63, 3)
	assert_eq(SaveSummaryTexts.badge_label(summary), "★ VICTOIRE")
	assert_eq(SaveSummaryTexts.badge_color(summary), AbyssColors.ENERGY_YELLOW)
	assert_eq(SaveSummaryTexts.meta_line(summary), "Tour 63 · Noyau · Facile")
	assert_eq(SaveSummaryTexts.footnote(summary), "Victoire")
	summary.volcanic_kernel_captured = true
	assert_eq(SaveSummaryTexts.footnote(summary), "Noyau Volcanique conquis")


func test_a_game_won_then_played_on_keeps_its_victory_and_its_resources() -> void:
	var summary := _summary(SaveOutcome.Value.FREE_PLAY, Difficulty.Value.EASY)
	assert_eq(SaveSummaryTexts.badge_label(summary), "★ VICTOIRE")
	assert_eq(SaveSummaryTexts.badge_color(summary), AbyssColors.ENERGY_YELLOW)
	assert_eq(SaveSummaryTexts.meta_line(summary), "Tour 14 · Profondeurs · QG niv. 3")
	assert_null(SaveSummaryTexts.footnote(summary))


func test_a_lost_game_tells_the_turn_its_base_fell_on() -> void:
	var summary := _summary(SaveOutcome.Value.DEFEAT, Difficulty.Value.HARD, 27, 1)
	assert_eq(SaveSummaryTexts.badge_label(summary), "DÉFAITE")
	assert_eq(SaveSummaryTexts.badge_color(summary), AbyssColors.ERROR)
	assert_eq(SaveSummaryTexts.meta_line(summary), "Tombée au tour 27 · Surface · Difficile")
	assert_eq(SaveSummaryTexts.footnote(summary), "Voir le bilan de la partie")


func test_names_who_plays_the_turn_and_the_difficulty() -> void:
	var summary := _summary(SaveOutcome.Value.IN_PROGRESS, Difficulty.Value.HARD)
	assert_eq(SaveSummaryTexts.resume_label(summary), "Alice · Tour 14 · Difficile")


func test_speaks_english_and_spanish() -> void:
	var summary := _summary(SaveOutcome.Value.IN_PROGRESS, Difficulty.Value.EASY)
	TranslationServer.set_locale("en")
	assert_eq(SaveSummaryTexts.badge_label(summary), "EASY")
	assert_eq(SaveSummaryTexts.resume_label(summary), "Alice · Turn 14 · Easy")
	var won := _summary(SaveOutcome.Value.VICTORY, Difficulty.Value.NORMAL)
	won.volcanic_kernel_captured = true
	assert_eq(SaveSummaryTexts.badge_label(won), "★ VICTORY")
	assert_eq(SaveSummaryTexts.footnote(won), "Volcanic Core conquered")
	var lost := _summary(SaveOutcome.Value.DEFEAT, Difficulty.Value.HARD, 27)
	assert_eq(SaveSummaryTexts.badge_label(lost), "DEFEAT")
	assert_true(SaveSummaryTexts.meta_line(lost).begins_with("Fell on turn 27 · "))
	assert_eq(SaveSummaryTexts.footnote(lost), "See the game report")
	TranslationServer.set_locale("es")
	assert_true(SaveSummaryTexts.meta_line(summary).begins_with("Turno 14 · "))
	assert_eq(SaveSummaryTexts.badge_label(won), "★ VICTORIA")


func _summary(outcome: SaveOutcome.Value, difficulty: Difficulty.Value, turn := 14,
		deepest := 2) -> SaveSummary:
	var resources: Dictionary[ResourceType.Value, int] = {}
	return SaveSummary.new("Alice", turn, difficulty, outcome, deepest, 3, resources, 0)
