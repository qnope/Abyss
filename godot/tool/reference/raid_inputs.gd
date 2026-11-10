class_name RaidInputs
extends RefCounted
## Writes and reads what a case of raids.json holds, as tool/vectors/domain/
## raid_vectors.dart does: a wave as `[difficulty, family, unitCount,
## secondFamily, secondCount]`, the families by their Dart names or null.


## A wave as a case writes it.
static func wave(lair: MonsterLair) -> Array:
	return [
		DartEnum.name_of(MonsterDifficulty.Value, lair.difficulty),
		VectorInputs.name_or_null(MonsterFamily.Value, lair.family),
		lair.unit_count,
		VectorInputs.name_or_null(MonsterFamily.Value, lair.second_family),
		lair.second_count,
	]
