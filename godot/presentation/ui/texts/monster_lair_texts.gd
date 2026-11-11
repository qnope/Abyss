class_name MonsterLairTexts
extends RefCounted
## lib/presentation/extensions/monster_lair_extensions.dart (MonsterLairDisplay):
## the wording of a group of monsters, used by the raid alerts and reports and
## by the defeat screen.


## `lair.waveLabel(l10n)`: "40 Dents-de-verre et 12 Calmars-chasseurs niv. 2".
static func wave_label(lair: MonsterLair) -> String:
	var monsters := ""
	var groups := lair.groups()
	for family: Variant in groups:
		var part := MonsterFamilyTexts.monsters(family, groups[family])
		monsters = part if monsters.is_empty() else Texts.t(&"monsterLairGroupsAnd", {"first": monsters, "second": part})
	return Texts.t(&"monsterLairWave", {"monsters": monsters, "level": lair.level()})


## `lair.weaknessLabel(l10n)`: "Faibles contre : Harponneurs, Gardiens", null
## when no family of the group has a weakness.
static func weakness_label(lair: MonsterLair) -> Variant:
	var answers := PackedStringArray()
	for family: Variant in lair.groups():
		var weakness: Variant = MonsterFamilyTexts.weakness(family)
		if weakness != null:
			answers.append(str(weakness))
	if answers.is_empty():
		return null
	return Texts.t(&"monsterLairWeakAgainst", {"units": ", ".join(answers)})
