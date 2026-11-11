class_name MonsterFamilyTexts
extends RefCounted
## lib/presentation/extensions/monster_family_extensions.dart
## (MonsterFamilyDisplay): wording of the monster families. A null family is
## the generic monster (Rôdeurs) of games started before them, so every
## function takes the family as a Variant: a MonsterFamily.Value or null.


## `family.label(l10n)`: "Carapaces".
static func label(family: Variant) -> String:
	return Texts.t(_key(family, "Label"))


## `family.monsters(l10n, count)`: "12 Isopodes cuirassés".
static func monsters(family: Variant, count: int) -> String:
	return Texts.t(_key(family, "Count"), {"count": count})


## `family.rule(l10n)`: the family's combat rule; null for the generic
## monsters.
static func rule(family: Variant) -> Variant:
	return null if family == null else Texts.t(_key(family, "Rule"))


## `family.weakness(l10n)`: the unit type that answers the family; null for
## the generic monsters. The kraken has the colossus' weakness.
static func weakness(family: Variant) -> Variant:
	if family == null:
		return null
	if family == MonsterFamily.Value.KRAKEN:
		return Texts.t(_key(MonsterFamily.Value.COLOSSUS, "Weakness"))
	return Texts.t(_key(family, "Weakness"))


static func _key(family: Variant, suffix: String) -> StringName:
	if family == null:
		return StringName("monsterFamilyGeneric" + suffix)
	var value: int = family
	return TextKeys.of("monsterFamily", MonsterFamily.Value, value, suffix)
