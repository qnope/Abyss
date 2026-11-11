class_name DifficultyTexts
extends RefCounted
## lib/presentation/extensions/difficulty_extensions.dart (DifficultyInfo):
## the names of the difficulties, in the language on, and the colour each is
## shown in.


## `difficulty.displayName(l10n)`: "Facile".
static func display_name(difficulty: Difficulty.Value) -> String:
	return Texts.t(TextKeys.of("difficulty", Difficulty.Value, difficulty, "Name"))


## `difficulty.description(l10n)`.
static func description(difficulty: Difficulty.Value) -> String:
	return Texts.t(TextKeys.of("difficulty", Difficulty.Value, difficulty, "Description"))


## `difficulty.color`: green for the easy game, cyan for the normal one, red
## for the hard one.
static func color(difficulty: Difficulty.Value) -> Color:
	match difficulty:
		Difficulty.Value.EASY:
			return AbyssColors.SUCCESS
		Difficulty.Value.HARD:
			return AbyssColors.ERROR
	return AbyssColors.BIOLUM_CYAN
