extends TextsTestCase
## MonsterDifficultyExtensions.label of lib/presentation/extensions/
## cell_content_type_extensions.dart, for the texts.

const Difficulty := MonsterDifficulty.Value


func test_names_each_difficulty_in_the_language_on() -> void:
	assert_eq(MonsterDifficultyTexts.label(Difficulty.EASY), "Facile")
	assert_eq(MonsterDifficultyTexts.label(Difficulty.HARD), "Difficile")
	TranslationServer.set_locale("en")
	assert_eq(MonsterDifficultyTexts.label(Difficulty.MEDIUM), "Medium")


func test_every_difficulty_has_its_text_in_every_language() -> void:
	assert_every_value_translated(Difficulty, func(difficulty: int) -> String:
		return TextKeys.of("monsterDifficulty", Difficulty, difficulty))
