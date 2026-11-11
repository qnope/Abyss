class_name DifficultyTexts
extends RefCounted
## lib/presentation/extensions/difficulty_extensions.dart (DifficultyInfo):
## the names of the difficulties, in the language on.


## `difficulty.displayName(l10n)`: "Facile".
static func display_name(difficulty: Difficulty.Value) -> String:
	return Texts.t(TextKeys.of("difficulty", Difficulty.Value, difficulty, "Name"))


## `difficulty.description(l10n)`.
static func description(difficulty: Difficulty.Value) -> String:
	return Texts.t(TextKeys.of("difficulty", Difficulty.Value, difficulty, "Description"))
