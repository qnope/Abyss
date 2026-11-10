class_name WarDigests
extends RefCounted
## The short texts the digest test of the wars between players
## (war_digest_test.gd) compares with what a scratch Dart script printed:
## an attack on a post or on a held kernel, the last assault entry of a
## player. Each text writes what the Dart script writes, in its order, the
## maps as `name:count`.


static func counts(map: Dictionary) -> String:
	return SiegeDigests.counts(map)


## The turns a map keyed by player ids holds, as `id:turn`.
static func turns(map: Dictionary) -> String:
	var parts := PackedStringArray()
	for id: String in map:
		parts.append("%s:%d" % [id, map[id]])
	return ",".join(parts)


## `turn defending victory opponent post units lost passage rampart a>b`
## of the last entry of `p`, or `-` when it is not an assault.
static func entry(p: Player) -> String:
	if p.history_entries.is_empty() or not p.history_entries[-1] is BaseAssaultEntry:
		return "-"
	var last: BaseAssaultEntry = p.history_entries[-1]
	return "%d %s %s %s %s %s %s %s %d>%d" % [
		last.turn, last.defending, last.victory, last.opponent_name,
		"null" if last.post_name == null else str(last.post_name), counts(last.units),
		counts(last.lost_with_post), last.passage_destroyed, last.rampart_before, last.rampart_after,
	]


## `V turns | sent | intact | wounded | dead | engaged | their intact |
## wounded | dead | rampart a>b hq a>b | units of `level` | their units of
## `below` | nN hN hN | entry | their entry`, or the failure's name.
static func assault(r: ActionResult, p: Player, owner: Player, level: int, below: int) -> String:
	if not r.is_success:
		var reason: int = r.reason
		return DartEnum.name_of(ActionFailure.Value, reason)
	var b: AttackBaseResult = r
	var d := b.damage
	return "%s %d | %s | %s | %s | %s | %s | %s | %s | %s | %d>%d %d>%d | %s | %s | n%d h%d h%d | %s | %s" % [
		"V" if b.victory else "L", b.fight.turn_count, counts(b.sent), counts(b.survivors_intact),
		counts(b.wounded), counts(b.dead), counts(b.defence.engaged), counts(b.defence.survivors_intact),
		counts(b.defence.wounded), counts(b.defence.dead), d.rampart_before, d.rampart_after,
		d.headquarters_before, d.headquarters_after, counts(p.unit_counts_on_level(level)),
		counts(owner.unit_counts_on_level(below)), p.raid_state.noise, p.history_entries.size(),
		owner.history_entries.size(), entry(p), entry(owner),
	]
