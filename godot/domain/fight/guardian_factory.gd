class_name GuardianFactory
extends RefCounted
## lib/domain/fight/guardian_factory.dart: the guardians of the posts and of
## the volcanic kernel, fresh at each call.


static func for_faille() -> Array[Combatant]:
	return _guarded(_boss("leviathan", 100, 15, 10), 5, "sentinelle", 30, 8, 4)


static func for_cheminee() -> Array[Combatant]:
	return _guarded(_boss("titanVolcanique", 200, 25, 15), 8, "golemMagma", 50, 12, 7)


## The final fight: about 130 units without Military research, 80 with all
## of it (see the conquest simulation).
static func for_volcanic_kernel() -> Array[Combatant]:
	return _guarded(_boss("seigneurNoyau", 1050, 35, 20), 30, "sentinelleNoyau", 80, 18, 10)


## A `switch` on both values in Dart: the Faille, else the Cheminée.
static func for_type(type: TransitionBaseType.Value) -> Array[Combatant]:
	if type == TransitionBaseType.Value.FAILLE:
		return for_faille()
	# cheminee, the last post.
	return for_cheminee()


static func _boss(key: String, hp: int, atk: int, def: int) -> Combatant:
	return Combatant.new(CombatSide.Value.MONSTER, key, hp, atk, def, null, true)


## `boss`, then `count` escorts of the stats given.
static func _guarded(
	boss: Combatant, count: int, key: String, hp: int, atk: int, def: int
) -> Array[Combatant]:
	var side: Array[Combatant] = [boss]
	for _i: int in count:
		side.append(Combatant.new(CombatSide.Value.MONSTER, key, hp, atk, def))
	return side
