extends TextsTestCase
## test/presentation/extensions/difficulty_extensions_test.dart, for the texts.

const Level := Difficulty.Value


func test_names_a_difficulty_and_describes_it() -> void:
	assert_eq(DifficultyTexts.display_name(Level.HARD), "Difficile")
	assert_eq(DifficultyTexts.description(Level.EASY), "Plus de ressources, des monstres moins nombreux.")
	TranslationServer.set_locale("en")
	assert_eq(DifficultyTexts.display_name(Level.HARD), "Hard")
	assert_eq(DifficultyTexts.description(Level.EASY), "More resources, fewer monsters.")


func test_every_difficulty_has_a_name_and_a_description_in_every_language() -> void:
	for suffix: String in ["Name", "Description"]:
		assert_every_value_translated(Level, func(level: int) -> String:
			return TextKeys.of("difficulty", Level, level, suffix))
