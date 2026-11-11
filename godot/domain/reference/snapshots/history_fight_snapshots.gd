class_name HistoryFightSnapshots
extends RefCounted
## lib/domain/reference/snapshots/history_fight_snapshots.dart: snapshots of
## the history entries that hold a fight.


static func combat() -> ClassSnapshot:
	var lairs := MapSnapshots.lair()
	var results := FightSnapshots.result()
	return HistoryEntrySnapshot.of("CombatEntry", {
		"victory": func(e: CombatEntry, _ids: PlayerIds) -> Variant: return e.victory,
		"targetX": func(e: CombatEntry, _ids: PlayerIds) -> Variant: return e.target_x,
		"targetY": func(e: CombatEntry, _ids: PlayerIds) -> Variant: return e.target_y,
		"lair": func(e: CombatEntry, ids: PlayerIds) -> Variant: return lairs.of(e.lair, ids),
		"fightResult": func(e: CombatEntry, ids: PlayerIds) -> Variant: return results.of(e.fight_result, ids),
		"loot": func(e: CombatEntry, _ids: PlayerIds) -> Variant: return _resources(e.loot),
		"sent": func(e: CombatEntry, _ids: PlayerIds) -> Variant: return _units(e.sent),
		"survivorsIntact": func(e: CombatEntry, _ids: PlayerIds) -> Variant: return _units(e.survivors_intact),
		"wounded": func(e: CombatEntry, _ids: PlayerIds) -> Variant: return _units(e.wounded),
		"dead": func(e: CombatEntry, _ids: PlayerIds) -> Variant: return _units(e.dead),
	})


static func capture() -> ClassSnapshot:
	var results := FightSnapshots.result()
	return HistoryEntrySnapshot.of("CaptureEntry", {
		"transitionBaseName": func(e: CaptureEntry, _ids: PlayerIds) -> Variant: return e.transition_base_name,
		"fightResult": func(e: CaptureEntry, ids: PlayerIds) -> Variant: return results.of(e.fight_result, ids),
		"captured": func(e: CaptureEntry, _ids: PlayerIds) -> Variant: return e.captured,
	})


static func raid() -> ClassSnapshot:
	var lairs := MapSnapshots.lair()
	var results := FightSnapshots.result()
	return HistoryEntrySnapshot.of("RaidEntry", {
		"victory": func(e: RaidEntry, _ids: PlayerIds) -> Variant: return e.victory,
		"wave": func(e: RaidEntry, ids: PlayerIds) -> Variant: return lairs.of(e.wave, ids),
		"fightResult": func(e: RaidEntry, ids: PlayerIds) -> Variant: return results.of(e.fight_result, ids),
		"loot": func(e: RaidEntry, _ids: PlayerIds) -> Variant: return _resources(e.loot),
		"pillaged": func(e: RaidEntry, _ids: PlayerIds) -> Variant: return _resources(e.pillaged),
		"defenders": func(e: RaidEntry, _ids: PlayerIds) -> Variant: return _units(e.defenders),
		"survivorsIntact": func(e: RaidEntry, _ids: PlayerIds) -> Variant: return _units(e.survivors_intact),
		"wounded": func(e: RaidEntry, _ids: PlayerIds) -> Variant: return _units(e.wounded),
		"dead": func(e: RaidEntry, _ids: PlayerIds) -> Variant: return _units(e.dead),
		"rampartLevel": func(e: RaidEntry, _ids: PlayerIds) -> Variant: return e.rampart_level,
		"surprise": func(e: RaidEntry, _ids: PlayerIds) -> Variant: return e.surprise,
	})


static func volcano() -> ClassSnapshot:
	var lairs := MapSnapshots.lair()
	var results := FightSnapshots.result()
	return HistoryEntrySnapshot.of("VolcanoEntry", {
		"victory": func(e: VolcanoEntry, _ids: PlayerIds) -> Variant: return e.victory,
		"wave": func(e: VolcanoEntry, ids: PlayerIds) -> Variant: return lairs.of(e.wave, ids),
		"fightResult": func(e: VolcanoEntry, ids: PlayerIds) -> Variant: return results.of(e.fight_result, ids),
		"kernelLevel": func(e: VolcanoEntry, _ids: PlayerIds) -> Variant: return e.kernel_level,
		"defenders": func(e: VolcanoEntry, _ids: PlayerIds) -> Variant: return _units(e.defenders),
		"survivorsIntact": func(e: VolcanoEntry, _ids: PlayerIds) -> Variant: return _units(e.survivors_intact),
		"wounded": func(e: VolcanoEntry, _ids: PlayerIds) -> Variant: return _units(e.wounded),
		"dead": func(e: VolcanoEntry, _ids: PlayerIds) -> Variant: return _units(e.dead),
	})


## The one class of entry without `title` nor `subtitle`, in Dart too.
static func assault() -> ClassSnapshot:
	var results := FightSnapshots.result()
	return HistoryEntrySnapshot.of("BaseAssaultEntry", {
		"victory": func(e: BaseAssaultEntry, _ids: PlayerIds) -> Variant: return e.victory,
		"defending": func(e: BaseAssaultEntry, _ids: PlayerIds) -> Variant: return e.defending,
		"opponentName": func(e: BaseAssaultEntry, _ids: PlayerIds) -> Variant: return e.opponent_name,
		"fightResult": func(e: BaseAssaultEntry, ids: PlayerIds) -> Variant: return results.of(e.fight_result, ids),
		"units": func(e: BaseAssaultEntry, _ids: PlayerIds) -> Variant: return _units(e.units),
		"survivorsIntact": func(e: BaseAssaultEntry, _ids: PlayerIds) -> Variant: return _units(e.survivors_intact),
		"wounded": func(e: BaseAssaultEntry, _ids: PlayerIds) -> Variant: return _units(e.wounded),
		"dead": func(e: BaseAssaultEntry, _ids: PlayerIds) -> Variant: return _units(e.dead),
		"rampartBefore": func(e: BaseAssaultEntry, _ids: PlayerIds) -> Variant: return e.rampart_before,
		"rampartAfter": func(e: BaseAssaultEntry, _ids: PlayerIds) -> Variant: return e.rampart_after,
		"headquartersBefore": func(e: BaseAssaultEntry, _ids: PlayerIds) -> Variant: return e.headquarters_before,
		"headquartersAfter": func(e: BaseAssaultEntry, _ids: PlayerIds) -> Variant: return e.headquarters_after,
		"pillaged": func(e: BaseAssaultEntry, _ids: PlayerIds) -> Variant: return _resources(e.pillaged),
		"loot": func(e: BaseAssaultEntry, _ids: PlayerIds) -> Variant: return _resources(e.loot),
		"postName": func(e: BaseAssaultEntry, _ids: PlayerIds) -> Variant: return e.post_name,
		"lostWithPost": func(e: BaseAssaultEntry, _ids: PlayerIds) -> Variant: return _units(e.lost_with_post),
		"passageDestroyed": func(e: BaseAssaultEntry, _ids: PlayerIds) -> Variant: return e.passage_destroyed,
	})


static func all() -> Array[ClassSnapshot]:
	return [combat(), capture(), raid(), volcano(), assault()]


static func _units(counts: Dictionary[UnitType.Value, int]) -> Array:
	return SnapshotValues.counts(counts, UnitType.Value)


static func _resources(counts: Dictionary[ResourceType.Value, int]) -> Array:
	return SnapshotValues.counts(counts, ResourceType.Value)
