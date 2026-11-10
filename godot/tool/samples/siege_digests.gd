class_name SiegeDigests
extends RefCounted
## The short texts the digest test of the sieges (siege_digest_test.gd)
## compares with what a scratch Dart script printed: an assault on the
## volcanic kernel, an attack on a base. Each text writes what the Dart
## script writes, in its order, the maps as `name:count`.


static func counts(map: Dictionary) -> String:
	return HistoryDigests.counts(map, UnitType.Value)


## `VC winner turns monsters>left | sent | intact | wounded | dead | units
## of level 3 | holder nN hN entry`, or the failure's name.
static func kernel(game: Game, p: Player, at: GridPosition, r: ActionResult) -> String:
	if not r.is_success:
		return _failure(r)
	var k: AttackVolcanicKernelResult = r
	var f := k.fight
	var entry := "-"
	if not p.history_entries.is_empty() and p.history_entries[-1] is CaptureEntry:
		var last: CaptureEntry = p.history_entries[-1]
		entry = "%d %s %s" % [last.turn, last.transition_base_name, last.captured]
	return "%s%s %s %d %d>%d | %s | %s | %s | %s | %s | %s n%d h%d %s" % [
		"V" if k.victory else "L", "C" if k.captured else "-", DartEnum.name_of(CombatSide.Value, f.winner),
		f.turn_count, f.initial_monster_count, f.final_monster_count, counts(k.sent),
		counts(k.survivors_intact), counts(k.wounded), counts(k.dead), counts(p.unit_counts_on_level(3)),
		holder(game.levels[3], at), p.raid_state.noise, p.history_entries.size(), entry,
	]


## `V turns | intact | wounded | dead | engaged | their intact | wounded |
## dead | rampart a>b hq a>b pillaged | loot | units | their units | nN hN
## hN`, or the failure's name.
static func base(p: Player, rival: Player, r: ActionResult) -> String:
	if not r.is_success:
		return _failure(r)
	var b: AttackBaseResult = r
	var d := b.damage
	var resources := func(map: Dictionary) -> String: return HistoryDigests.counts(map, ResourceType.Value)
	return "%s %d | %s | %s | %s | %s | %s | %s | %s | %d>%d %d>%d %s | %s | %s | %s | n%d h%d h%d" % [
		"V" if b.victory else "L", b.fight.turn_count, counts(b.survivors_intact), counts(b.wounded),
		counts(b.dead), counts(b.defence.engaged), counts(b.defence.survivors_intact),
		counts(b.defence.wounded), counts(b.defence.dead), d.rampart_before, d.rampart_after,
		d.headquarters_before, d.headquarters_after, resources.call(d.pillaged), resources.call(d.loot),
		counts(p.unit_counts_on_level(1)), counts(rival.unit_counts_on_level(1)), p.raid_state.noise,
		p.history_entries.size(), rival.history_entries.size(),
	]


## The id of the player who holds the cell at `at`, "null" for none, as
## Dart prints it.
static func holder(map: GameMap, at: GridPosition) -> String:
	var id: Variant = map.cell_at(at.x, at.y).collected_by
	return "null" if id == null else str(id)


static func _failure(r: ActionResult) -> String:
	var reason: int = r.reason
	return DartEnum.name_of(ActionFailure.Value, reason)
