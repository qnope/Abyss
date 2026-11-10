class_name HistoryDigests
extends RefCounted
## The short texts the digest tests compare the history entries with, as a
## scratch Dart script printed them on the same games: the number of
## entries each player holds after each turn, then each entry.


## Appends to `sizes[id]` the number of entries each player holds.
static func count_entries(game: Game, sizes: Dictionary) -> void:
	for player: Player in game.players.values():
		var held: PackedStringArray = sizes[player.id]
		held.append(str(player.history_entries.size()))


## The entries counted after each turn, then each entry `player` holds.
static func history(player: Player, sizes: PackedStringArray) -> Array:
	var texts: Array = [" ".join(sizes)]
	for e: HistoryEntry in player.history_entries:
		texts.append(entry(e))
	return texts


## A history entry of a fight: `raid turn V|L wave fight rN surprise |
## loot | pillaged | defenders | intact | wounded | dead` or `volcano turn
## V|L wave fight kN | defenders | intact | wounded | dead`, the wave as
## RaidDigests.wave, the fight as `winner turns monsters>left`, each map as
## `name:count` in its order; another entry as `category turn`.
static func entry(e: HistoryEntry) -> String:
	var units := UnitType.Value
	if e is RaidEntry:
		var r := e as RaidEntry
		return "raid %d %s %s %s r%d %s | %s | %s | %s | %s | %s | %s" % [
			r.turn, _won(r.victory), RaidDigests.wave(r.wave), _fight(r.fight_result),
			r.rampart_level, r.surprise, counts(r.loot, ResourceType.Value),
			counts(r.pillaged, ResourceType.Value), counts(r.defenders, units),
			counts(r.survivors_intact, units), counts(r.wounded, units), counts(r.dead, units),
		]
	if e is VolcanoEntry:
		var v := e as VolcanoEntry
		return "volcano %d %s %s %s k%d | %s | %s | %s | %s" % [
			v.turn, _won(v.victory), RaidDigests.wave(v.wave), _fight(v.fight_result),
			v.kernel_level, counts(v.defenders, units), counts(v.survivors_intact, units),
			counts(v.wounded, units), counts(v.dead, units),
		]
	return "%s %d" % [DartEnum.name_of(HistoryEntryCategory.Value, e.category), e.turn]


## `name:count` for each entry of `map`, in its order, joined by commas.
static func counts(map: Dictionary, enumeration: Dictionary) -> String:
	var parts := PackedStringArray()
	for key: int in map:
		parts.append("%s:%d" % [DartEnum.name_of(enumeration, key), map[key]])
	return ",".join(parts)


static func _won(victory: bool) -> String:
	return "V" if victory else "L"


static func _fight(f: FightResult) -> String:
	return "%s %d %d>%d" % [
		DartEnum.name_of(CombatSide.Value, f.winner), f.turn_count, f.initial_monster_count,
		f.final_monster_count,
	]
