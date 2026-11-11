class_name HistoryFightCodec
extends RefCounted
## The entries of the history that hold a fight, in a save: their own
## fields, which HistoryCodec writes after the turn and the category.

const Category := HistoryEntryCategory.Value
## The categories of the entries that hold a fight, a set.
const FIGHTS: Dictionary[Category, bool] = {
	Category.COMBAT: true, Category.CAPTURE: true, Category.RAID: true, Category.VOLCANO: true,
	Category.ASSAULT: true,
}


static func own(x: HistoryEntry) -> Dictionary:
	match x.category:
		Category.CAPTURE:
			var e := x as CaptureEntry
			return {
				"transitionBaseName": e.transition_base_name, "fightResult": FightCodec.result(e.fight_result),
				"captured": e.captured,
			}
		Category.RAID:
			var e := x as RaidEntry
			return {
				"victory": e.victory, "wave": MapCodec.lair(e.wave), "fightResult": FightCodec.result(e.fight_result),
				"loot": _resources(e.loot), "pillaged": _resources(e.pillaged), "defenders": _units(e.defenders),
				"survivorsIntact": _units(e.survivors_intact), "wounded": _units(e.wounded), "dead": _units(e.dead),
				"rampartLevel": e.rampart_level, "surprise": e.surprise,
			}
		Category.VOLCANO:
			var e := x as VolcanoEntry
			return {
				"victory": e.victory, "wave": MapCodec.lair(e.wave), "fightResult": FightCodec.result(e.fight_result),
				"kernelLevel": e.kernel_level, "defenders": _units(e.defenders),
				"survivorsIntact": _units(e.survivors_intact), "wounded": _units(e.wounded), "dead": _units(e.dead),
			}
		Category.ASSAULT:
			var e := x as BaseAssaultEntry
			return {
				"victory": e.victory, "defending": e.defending, "opponentName": e.opponent_name,
				"fightResult": FightCodec.result(e.fight_result), "units": _units(e.units),
				"survivorsIntact": _units(e.survivors_intact), "wounded": _units(e.wounded), "dead": _units(e.dead),
				"rampartBefore": e.rampart_before, "rampartAfter": e.rampart_after,
				"headquartersBefore": e.headquarters_before, "headquartersAfter": e.headquarters_after,
				"pillaged": _resources(e.pillaged), "loot": _resources(e.loot), "postName": e.post_name,
				"lostWithPost": _units(e.lost_with_post), "passageDestroyed": e.passage_destroyed,
			}
	# Category.COMBAT
	var c := x as CombatEntry
	return {
		"victory": c.victory, "targetX": c.target_x, "targetY": c.target_y, "lair": MapCodec.lair(c.lair),
		"fightResult": FightCodec.result(c.fight_result), "loot": _resources(c.loot), "sent": _units(c.sent),
		"survivorsIntact": _units(c.survivors_intact), "wounded": _units(c.wounded), "dead": _units(c.dead),
	}


## The entry of `category` (one of FIGHTS) and `turn`, its fields in `m`.
static func read_own(r: SaveReader, m: Dictionary, turn: int, category: Category) -> HistoryEntry:
	var fight := FightCodec.read_result(r, r.at(m, "fightResult"))
	match category:
		Category.CAPTURE:
			return CaptureEntry.new(turn, r.text_at(m, "transitionBaseName"), fight, r.bool_at(m, "captured"))
		Category.RAID:
			return RaidEntry.new(
				turn, r.bool_at(m, "victory"), MapCodec.read_lair(r, r.at(m, "wave")), fight, _r(r, m, "loot"),
				_r(r, m, "pillaged"), _u(r, m, "defenders"), _u(r, m, "survivorsIntact"), _u(r, m, "wounded"),
				_u(r, m, "dead"), r.int_at(m, "rampartLevel"), r.bool_at(m, "surprise"))
		Category.VOLCANO:
			return VolcanoEntry.new(
				turn, r.bool_at(m, "victory"), MapCodec.read_lair(r, r.at(m, "wave")), fight, r.int_at(m, "kernelLevel"),
				_u(r, m, "defenders"), _u(r, m, "survivorsIntact"), _u(r, m, "wounded"), _u(r, m, "dead"))
		Category.ASSAULT:
			return BaseAssaultEntry.new(
				turn, r.bool_at(m, "victory"), r.bool_at(m, "defending"), r.text_at(m, "opponentName"), fight,
				_u(r, m, "units"), _u(r, m, "survivorsIntact"), _u(r, m, "wounded"), _u(r, m, "dead"),
				r.int_at(m, "rampartBefore"), r.int_at(m, "rampartAfter"), r.int_at(m, "headquartersBefore"),
				r.int_at(m, "headquartersAfter"), _r(r, m, "pillaged"), _r(r, m, "loot"),
				r.text_or_null_at(m, "postName"), _u(r, m, "lostWithPost"), r.bool_at(m, "passageDestroyed"))
	# Category.COMBAT
	return CombatEntry.new(
		turn, r.bool_at(m, "victory"), r.int_at(m, "targetX"), r.int_at(m, "targetY"),
		MapCodec.read_lair(r, r.at(m, "lair")), fight, _r(r, m, "loot"), _u(r, m, "sent"),
		_u(r, m, "survivorsIntact"), _u(r, m, "wounded"), _u(r, m, "dead"))


static func _units(counts: Dictionary[UnitType.Value, int]) -> Dictionary:
	return SaveValues.counts(counts, UnitType.Value)


static func _resources(counts: Dictionary[ResourceType.Value, int]) -> Dictionary:
	return SaveValues.counts(counts, ResourceType.Value)


static func _u(r: SaveReader, m: Dictionary, key: String) -> Dictionary:
	return SaveCollections.counts_at(r, m, key, UnitType.Value)


static func _r(r: SaveReader, m: Dictionary, key: String) -> Dictionary:
	return SaveCollections.counts_at(r, m, key, ResourceType.Value)
