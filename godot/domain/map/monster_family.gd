class_name MonsterFamily
extends RefCounted
## lib/domain/map/monster_family.dart: kind of monster a lair or a raid wave
## is made of. Each family has its own stats and one combat rule, and a
## unit type that answers it.

enum Value {
	## Dents-de-verre: many fragile fish. A Harponneur's hit strikes two.
	SWARM,
	## Isopodes cuirassés: a huge DEF that only Saboteurs ignore.
	ARMOURED,
	## Calmars-chasseurs: they hunt the frailest unit and hit it twice as
	## hard, unless a taunting unit draws them.
	HUNTER,
	## Requins dormeurs: a few giants, all bosses, that Briseurs hit twice.
	COLOSSUS,
	## Le terrifiant Kraken: it only rises from the volcano to take the
	## kernel back. A boss whose tentacles strike two defenders at once.
	KRAKEN,
}

const _BEFORE_LEVEL_2: Array[Value] = [Value.SWARM, Value.ARMOURED, Value.HUNTER]
const _FROM_LEVEL_2: Array[Value] = [Value.SWARM, Value.ARMOURED, Value.HUNTER, Value.COLOSSUS]


## Families that can make up a lair or a raid of `level` monsters: colossi
## only show up from level 2, the kraken never leaves the volcano. A
## constant list, as in Dart.
static func available_at(level: int) -> Array[Value]:
	return _BEFORE_LEVEL_2 if level < 2 else _FROM_LEVEL_2


## `family.isBoss`: whether the monsters of this family fight as bosses,
## that Briseurs hit twice.
static func is_boss(family: Value) -> bool:
	return family == Value.COLOSSUS or family == Value.KRAKEN


## Combatant key of a monster of `family` (a Value, or null) at `level`; the
## generic monsters of older games keep their `monsterL<level>` key.
static func type_key_of(family: Variant, level: int) -> String:
	var name := "monster"
	if family != null:
		var known: Value = family
		name = DartEnum.name_of(Value, known)
	return "%sL%d" % [name, level]


## Family of a monster combatant key (a Value), or null for player units and
## the generic monsters of older games.
static func of_type_key(type_key: String) -> Variant:
	var cut := type_key.rfind("L")
	if cut <= 0:
		return null
	return DartEnum.by_name(Value, type_key.substr(0, cut))
