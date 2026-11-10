class_name AttackBaseEntries
extends RefCounted
## lib/domain/action/attack_base_entries.dart: the two history entries of an
## attack on a base, or on a post when `post_name` is given: one for each
## side.


## The entry of the attacker, who sent `AttackBaseResult.sent`.
static func for_attacker(
	turn: int, defender_name: String, r: AttackBaseResult, post_name: Variant = null
) -> BaseAssaultEntry:
	return _entry(turn, defender_name, r, false, post_name)


## The entry of the defender, who fielded the base's units and lost
## `lost_with_post` with the post or the kernel taken, and the passage
## building of the post when `passage_destroyed`.
static func for_defender(
	turn: int,
	attacker_name: String,
	r: AttackBaseResult,
	post_name: Variant = null,
	lost_with_post: Dictionary[UnitType.Value, int] = {},
	passage_destroyed := true,
) -> BaseAssaultEntry:
	return _entry(turn, attacker_name, r, true, post_name, lost_with_post, passage_destroyed)


static func _entry(
	turn: int,
	opponent_name: String,
	r: AttackBaseResult,
	defending: bool,
	post_name: Variant,
	lost_with_post: Dictionary[UnitType.Value, int] = {},
	passage_destroyed := true,
) -> BaseAssaultEntry:
	var units := r.sent
	var intact := r.survivors_intact
	var wounded := r.wounded
	var dead := r.dead
	if defending:
		units = r.defence.engaged
		intact = r.defence.survivors_intact
		wounded = r.defence.wounded
		dead = r.defence.dead
	var d := r.damage
	return BaseAssaultEntry.new(
		turn, r.victory, defending, opponent_name, r.fight, units, intact, wounded, dead,
		d.rampart_before, d.rampart_after, d.headquarters_before, d.headquarters_after,
		d.pillaged, d.loot, post_name, lost_with_post, passage_destroyed,
	)
