class_name MonsterDifficultyTexts
extends RefCounted
## lib/presentation/extensions/cell_content_type_extensions.dart
## (MonsterDifficultyExtensions.label): "Facile", "Moyen", "Difficile".


## The name of [param difficulty] in the language on.
static func label(difficulty: MonsterDifficulty.Value) -> String:
	return Texts.t(TextKeys.of("monsterDifficulty", MonsterDifficulty.Value, difficulty))
