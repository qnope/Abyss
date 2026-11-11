class_name AssaultMoves
extends RefCounted
## lib/domain/script/strategies/assault_moves.dart: moves against the base
## or the posts of another player. The Dart extension on ScriptTurn: each
## function takes the turn first.


## Sends `army` of the base level against the base of player `target_id`;
## returns whether the attack was made. The caller picks a target it knows
## and an army worth sending.
static func attack_base(turn: ScriptTurn, target_id: String, army: Dictionary[UnitType.Value, int]) -> bool:
	return turn.try_perform(AttackBaseAction.new(target_id, army, turn.random()))


## Sends `army` of `level` against the post at (`x`, `y`) of that level,
## held by another player; returns whether the attack was made.
static func attack_post(
	turn: ScriptTurn, level: int, x: int, y: int, army: Dictionary[UnitType.Value, int]
) -> bool:
	return turn.try_perform(AttackPostAction.new(x, y, level, army, turn.random()))


## Sends a Scout to the base of player `target_id`, who has to be one the
## player has seen; returns whether the report came back.
static func spy_on(turn: ScriptTurn, target_id: String) -> bool:
	return turn.try_perform(SpyBaseAction.new(target_id))


## Announces an attack with `army` on the human player; returns whether it
## was announced. Only another player than the human can announce.
static func announce_attack(turn: ScriptTurn, army: Dictionary[UnitType.Value, int]) -> bool:
	return turn.try_perform(AnnounceAttackAction.new(army, turn.random()))
