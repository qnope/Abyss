class_name PostAssaultSettlement
extends RefCounted
## lib/domain/action/post_assault_settlement.dart: the end of an attack on a
## post: the takeover (PostTakeover) when the attacker won, then the report
## its owner keeps of the fight. The attack, whatever its outcome, starts
## the AttackCooldown of a player.


## Settles `result` of `attacker_name`'s attack on `post`, held by `owner`,
## during `turn`: `attacker` takes it on a win (null for the guardians, who
## guard it again). Returns the owner's entry, already in its history.
static func settle(
	turn: int,
	post: TransitionBase,
	attacker: Player,
	attacker_name: String,
	owner: Player,
	result: AttackBaseResult,
) -> BaseAssaultEntry:
	var lost := PostTakeover.apply(post, attacker, owner) if result.victory else PostLoss.none()
	if attacker != null:
		AttackCooldown.post_attacked(turn, attacker, owner)
	var entry := AttackBaseEntries.for_defender(
		turn, attacker_name, result, post.name, lost.units, lost.passage
	)
	owner.add_history_entry(entry)
	return entry
