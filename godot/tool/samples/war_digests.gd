class_name WarDigests
extends RefCounted
## The short texts the digest test of the wars between players
## (war_digest_test.gd) compares with what a scratch Dart script printed:
## an attack on a post or on a held kernel, the last assault entry of a
## player. Each text writes what the Dart script writes, in its order, the
## maps as `name:count`.


static func counts(map: Dictionary) -> String:
	return SiegeDigests.counts(map)


## The first cell of `map`, row by row, where `ok(x, y)`.
static func first(map: GameMap, ok: Callable) -> GridPosition:
	for y: int in map.height:
		for x: int in map.width:
			if ok.call(x, y):
				return GridPosition.new(x, y)
	return GridPosition.new(-1, -1)


## Puts exactly `units` on the stock of `level` of `p`.
static func put(p: Player, level: int, units: Dictionary[UnitType.Value, int]) -> void:
	for unit: Unit in KernelGarrison.stock_at(p, level).values():
		unit.count = units.get(unit.type, 0)


## A value as Dart prints it: "null" for null.
static func text(value: Variant) -> String:
	return "null" if value == null else str(value)


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
		text(last.post_name), counts(last.units),
		counts(last.lost_with_post), last.passage_destroyed, last.rampart_before, last.rampart_after,
	]


## `V turns | sent | intact | wounded | dead | engaged | their intact |
## wounded | dead | rampart a>b hq a>b | units of `level` | their units of
## `below` | nN hN hN | entry | their entry`, or the failure's name.
static func assault(r: ActionResult, p: Player, owner: Player, level: int, below: int) -> String:
	if not r.is_success:
		return outcome(r)
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


## "ok", or the name of the failure of `r`.
static func outcome(r: ActionResult) -> String:
	if r.is_success:
		return "ok"
	var reason: int = r.reason
	return DartEnum.name_of(ActionFailure.Value, reason)


## The attacks pending on the base of `human`, as `attacker units turn
## seed`, joined by `; `.
static func pending(human: Player) -> String:
	var parts := PackedStringArray()
	for a: AnnouncedAttack in human.raid_state.attacks:
		parts.append("%s %s %d %d" % [a.attacker_id, counts(a.units), a.arrival_turn, a.fight_seed])
	return "; ".join(parts)


## The attacks the factions decide on the base of the human `p` from turn
## 60, as the digest test reads them: each outcome, the attacks pending and
## the units, noise and history of the faction.
static func announces(game: Game, p: Player, rival: Player, other: Player, seed_: int) -> Array[String]:
	var lines: Array[String] = []
	var gap := Difficulty.attack_gap(game.difficulty())
	var announce := func(by: Player, army: Dictionary[UnitType.Value, int], dice: int) -> String:
		var r := ActionExecutor.new().execute(AnnounceAttackAction.new(army, DartRandom.new(dice)), game, by)
		return "%s | %s | %s n%d h%d" % [
			outcome(r), pending(p), counts(by.unit_counts_on_level(1)), by.raid_state.noise, by.history_entries.size(),
		]
	game.turn = 60
	put(rival, 1, {UnitType.Value.HARPOONIST: 30, UnitType.Value.GUARDIAN: 4})
	var others: Dictionary[UnitType.Value, int] = {UnitType.Value.HARPOONIST: 20, UnitType.Value.SCOUT: 2}
	put(other, 1, others)
	var first_army: Dictionary[UnitType.Value, int] = {UnitType.Value.HARPOONIST: 12, UnitType.Value.GUARDIAN: 0}
	var five: Dictionary[UnitType.Value, int] = {UnitType.Value.HARPOONIST: 5}
	lines.append(announce.call(rival, first_army, seed_ + 600))
	lines.append(announce.call(rival, five, seed_ + 601))
	lines.append(announce.call(other, five, seed_ + 602))
	game.turn = 60 + gap
	p.raid_state.attacks.clear()
	p.raid_state.announce(MonsterLair.new(MonsterDifficulty.Value.EASY, 3), game.turn)
	lines.append(announce.call(other, others, seed_ + 603))
	game.turn = 61 + gap
	lines.append(announce.call(other, others, seed_ + 604))
	var too_many: Dictionary[UnitType.Value, int] = {UnitType.Value.HARPOONIST: 31}
	lines.append(announce.call(rival, too_many, seed_ + 605))
	return lines
