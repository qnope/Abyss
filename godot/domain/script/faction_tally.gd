class_name FactionTally
extends RefCounted
## lib/domain/script/faction_tally.dart: counts what each player did in a
## replay journal: the decoded actions of each turn (`ReplayJournal
## .actions_of`, or the `turns` of an exported replay). A move without
## `player` key is the human's (`human`).

const _LEVELED: Array[String] = ["explore", "collect"]
const _BRANCHED: Array[String] = ["unlock", "research"]

## Counters per player id, each a `Dictionary[String, int]` by name such as
## `upgrade`, `explore@3`, `collect@2`, `attackPlayer`, `unlock:explorer`.
var counts: Dictionary[String, Dictionary] = {}
## Level of the held kernel when the factions of a turn played (0 or
## absent: nobody held it); filled by whoever watches the game.
var kernel_level_at: Dictionary[int, int] = {}
## Faction attacks on a held kernel, by the level the kernel stood at that
## turn (the human's own attacks are left out).
var held_kernel_by_level: Dictionary[int, int] = {}


func bump(who: String, key: String, by := 1) -> void:
	if not counts.has(who):
		var fresh: Dictionary[String, int] = {}
		counts[who] = fresh
	var c: Dictionary[String, int] = counts[who]
	c[key] = c.get(key, 0) + by


func of(who: String, key: String) -> int:
	if not counts.has(who):
		return 0
	var c: Dictionary[String, int] = counts[who]
	return c.get(key, 0)


## The counted players other than the human, sorted.
func faction_ids() -> Array[String]:
	var ids: Array[String] = []
	for who: String in counts:
		if who != "human":
			ids.append(who)
	CanonicalKeys.sort(ids)
	return ids


## Notes that `who` took part in `turns` more turns (a faction drawn in only
## some games of a batch counts only those).
func played(who: String, turns: int) -> void:
	bump(who, "turns", turns)


## `key` per turn `who` took part in (0 if it never played).
func per_turn(who: String, key: String) -> float:
	var turns := of(who, "turns")
	return 0.0 if turns == 0 else DartMath.quotient(of(who, key), turns)


## `key` per turn of a faction, over all `faction_ids` (0 without any).
func faction_mean(key: String) -> float:
	var n := 0
	var turns := 0
	for who: String in faction_ids():
		n += of(who, key)
		turns += of(who, "turns")
	return 0.0 if turns == 0 else DartMath.quotient(n, turns)


## Adds the moves of each `[turn, moves]` of `journal`, Dart's records
## `(int, List<Map>)`.
func add_journal(journal: Array) -> void:
	for entry: Array in journal:
		var turn: int = entry[0]
		var level: int = kernel_level_at.get(turn, 0)
		for m: Dictionary in entry[1]:
			_add(m, level)


func _add(m: Dictionary, kernel_level: int) -> void:
	var who: String = m.get("player") if m.get("player") != null else "human"
	var verb: String = m["do"]
	bump(who, verb)
	if _LEVELED.has(verb):
		bump(who, "%s@%s" % [verb, _text(m.get("level")) if m.get("level") != null else "1"])
	if _BRANCHED.has(verb):
		bump(who, "%s:%s" % [verb, _text(m.get("branch"))])
	if verb == "attackPlayer" and m.get("target") == "human":
		bump(who, "attackHuman")
	if verb == "attackHeldKernel" and who != "human":
		held_kernel_by_level[kernel_level] = held_kernel_by_level.get(kernel_level, 0) + 1


## Adds the counters of `other`, to sum a batch.
func merge(other: FactionTally) -> void:
	for who: String in other.counts:
		var c: Dictionary[String, int] = other.counts[who]
		for key: String in c:
			bump(who, key, c[key])
	for level: int in other.held_kernel_by_level:
		held_kernel_by_level[level] = held_kernel_by_level.get(level, 0) + other.held_kernel_by_level[level]


## Dart's text of a value of a move: `null` for null.
static func _text(value: Variant) -> String:
	return "null" if value == null else str(value)
