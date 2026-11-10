class_name AttackCooldown
extends RefCounted
## lib/domain/action/attack_cooldown.dart: the rest a player gets from one
## attacker, the same for everyone (the human and the factions, whatever
## the difficulty): after attacking the posts of a player, an attacker waits
## TURNS turns before attacking its posts again, and as long after
## besieging its kernel before besieging it again, whatever the outcome.
## Posts and kernel are counted apart, and the other attackers may strike
## the very next turn.
##
## The turns are kept by the attacker (`RaidState.post_attack_turns`,
## `RaidState.kernel_attack_turns`), not read from its capped history.

## Turns between two attacks of one attacker on one target: attacking on
## turn t allows the next on turn t + TURNS.
const TURNS := 4


## Whether `attacker` must still wait before attacking a post of `owner`.
static func on_posts(game: Game, attacker: Player, owner: Player) -> bool:
	return _too_soon(game.turn, attacker.raid_state.post_attack_turns.get(owner.id))


## Whether `attacker` must still wait before besieging the kernel `holder`
## holds.
static func on_kernel(game: Game, attacker: Player, holder: Player) -> bool:
	return _too_soon(game.turn, attacker.raid_state.kernel_attack_turns.get(holder.id))


## Dates the attack of `attacker` on a post of `owner` during `turn`.
static func post_attacked(turn: int, attacker: Player, owner: Player) -> void:
	attacker.raid_state.post_attack_turns[owner.id] = turn


## Dates the siege of `attacker` on the kernel of `holder` during `turn`.
static func kernel_attacked(turn: int, attacker: Player, holder: Player) -> void:
	attacker.raid_state.kernel_attack_turns[holder.id] = turn


static func _too_soon(turn: int, last: Variant) -> bool:
	if last == null:
		return false
	var since: int = turn - last
	return since < TURNS
