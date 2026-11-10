class_name CombatSide
extends RefCounted
## lib/domain/fight/combat_side.dart: the two sides of a fight.

enum Value { PLAYER, MONSTER }


## `side.opponent`.
static func opponent(side: Value) -> Value:
	return Value.MONSTER if side == Value.PLAYER else Value.PLAYER
