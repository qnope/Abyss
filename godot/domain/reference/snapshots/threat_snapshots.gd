class_name ThreatSnapshots
extends RefCounted
## lib/domain/reference/snapshots/threat_snapshots.dart: snapshots of what
## comes at a player, raids, attacks of factions, kraken waves, random
## events, the guardians' return, and what its scouts know of the others.


static func attack() -> ClassSnapshot:
	return ClassSnapshot.new("AnnouncedAttack", {
		"attackerId": func(a: AnnouncedAttack, ids: PlayerIds) -> Variant: return ids.of(a.attacker_id),
		"units": func(a: AnnouncedAttack, _ids: PlayerIds) -> Variant: return SnapshotValues.counts(a.units, UnitType.Value),
		"arrivalTurn": func(a: AnnouncedAttack, _ids: PlayerIds) -> Variant: return a.arrival_turn,
		"seed": func(a: AnnouncedAttack, _ids: PlayerIds) -> Variant: return a.fight_seed,
	})


static func raid() -> ClassSnapshot:
	var lairs := MapSnapshots.lair()
	var attacks := attack()
	return ClassSnapshot.new("RaidState", {
		"noise": func(r: RaidState, _ids: PlayerIds) -> Variant: return r.noise,
		"totalNoise": func(r: RaidState, _ids: PlayerIds) -> Variant: return r.total_noise,
		"incoming": func(r: RaidState, ids: PlayerIds) -> Variant: return lairs.or_null(r.incoming, ids),
		"arrivalTurn": func(r: RaidState, _ids: PlayerIds) -> Variant: return r.arrival_turn,
		"lostInARow": func(r: RaidState, _ids: PlayerIds) -> Variant: return r.lost_in_a_row,
		"raidsRepelled": func(r: RaidState, _ids: PlayerIds) -> Variant: return r.raids_repelled,
		"raidsLost": func(r: RaidState, _ids: PlayerIds) -> Variant: return r.raids_lost,
		"attacks": func(r: RaidState, ids: PlayerIds) -> Variant: return attacks.list_of(r.attacks, ids),
		"kernelSiegeLostTurn": func(r: RaidState, _ids: PlayerIds) -> Variant: return r.kernel_siege_lost_turn,
		"postAttackTurns": func(r: RaidState, ids: PlayerIds) -> Variant: return _turns_by_id(r.post_attack_turns, ids),
		"kernelAttackTurns": func(r: RaidState, ids: PlayerIds) -> Variant: return _turns_by_id(r.kernel_attack_turns, ids),
	})


static func volcano() -> ClassSnapshot:
	var lairs := MapSnapshots.lair()
	return ClassSnapshot.new("VolcanoState", {
		"incoming": func(v: VolcanoState, ids: PlayerIds) -> Variant: return lairs.or_null(v.incoming, ids),
		"arrivalTurn": func(v: VolcanoState, _ids: PlayerIds) -> Variant: return v.arrival_turn,
		"wavesRepelled": func(v: VolcanoState, _ids: PlayerIds) -> Variant: return v.waves_repelled,
		"levelsLost": func(v: VolcanoState, _ids: PlayerIds) -> Variant: return v.levels_lost,
	})


static func event() -> ClassSnapshot:
	var lairs := MapSnapshots.lair()
	var positions := MapSnapshots.position()
	var event_name := func(type: Variant) -> Variant: return SnapshotValues.name_or_null(RandomEventType.Value, type)
	var resource_name := func(type: Variant) -> Variant: return SnapshotValues.name_or_null(ResourceType.Value, type)
	return ClassSnapshot.new("EventState", {
		"nextDrawTurn": func(e: EventState, _ids: PlayerIds) -> Variant: return e.next_draw_turn,
		"pending": func(e: EventState, _ids: PlayerIds) -> Variant: return event_name.call(e.pending),
		"pendingTurn": func(e: EventState, _ids: PlayerIds) -> Variant: return e.pending_turn,
		"lastDrawn": func(e: EventState, _ids: PlayerIds) -> Variant: return event_name.call(e.last_drawn),
		"active": func(e: EventState, _ids: PlayerIds) -> Variant: return event_name.call(e.active),
		"activeUntilTurn": func(e: EventState, _ids: PlayerIds) -> Variant: return e.active_until_turn,
		"heating": func(e: EventState, _ids: PlayerIds) -> Variant: return e.heating,
		"eventsSeen": func(e: EventState, _ids: PlayerIds) -> Variant: return e.events_seen,
		"survivors": func(e: EventState, _ids: PlayerIds) -> Variant: return e.survivors,
		"tradeFrom": func(e: EventState, _ids: PlayerIds) -> Variant: return resource_name.call(e.trade_from),
		"tradeTo": func(e: EventState, _ids: PlayerIds) -> Variant: return resource_name.call(e.trade_to),
		"predatorWave": func(e: EventState, ids: PlayerIds) -> Variant: return lairs.or_null(e.predator_wave, ids),
		"predatorsTurn": func(e: EventState, _ids: PlayerIds) -> Variant: return e.predators_turn,
		"wreckPosition": func(e: EventState, ids: PlayerIds) -> Variant: return positions.or_null(e.wreck_position, ids),
		"wreckUntilTurn": func(e: EventState, _ids: PlayerIds) -> Variant: return e.wreck_until_turn,
	})


static func leviathan() -> ClassSnapshot:
	var positions := MapSnapshots.position()
	return ClassSnapshot.new("LeviathanReturn", {
		"postName": func(l: LeviathanReturn, _ids: PlayerIds) -> Variant: return l.post_name,
		"level": func(l: LeviathanReturn, _ids: PlayerIds) -> Variant: return l.level,
		"at": func(l: LeviathanReturn, ids: PlayerIds) -> Variant: return positions.or_null(l.at, ids),
		"strikeTurn": func(l: LeviathanReturn, _ids: PlayerIds) -> Variant: return l.strike_turn,
		"over": func(l: LeviathanReturn, _ids: PlayerIds) -> Variant: return l.over,
		"readyTurn": func(l: LeviathanReturn, _ids: PlayerIds) -> Variant: return l.ready_turn,
	})


static func intel() -> ClassSnapshot:
	return ClassSnapshot.new("BaseIntel", {
		"turn": func(i: BaseIntel, _ids: PlayerIds) -> Variant: return i.turn,
		"headquartersLevel": func(i: BaseIntel, _ids: PlayerIds) -> Variant: return i.headquarters_level,
		"rampartLevel": func(i: BaseIntel, _ids: PlayerIds) -> Variant: return i.rampart_level,
		"army": func(i: BaseIntel, _ids: PlayerIds) -> Variant: return SnapshotValues.counts(i.army, UnitType.Value),
		"stocks": func(i: BaseIntel, _ids: PlayerIds) -> Variant: return SnapshotValues.counts(i.stocks, ResourceType.Value),
	})


static func _turns_by_id(turns: Dictionary[String, int], ids: PlayerIds) -> Array:
	return SnapshotValues.pairs(turns, ids.of, func(turn: int) -> Variant: return turn)
