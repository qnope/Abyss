class_name ThreatCodec
extends RefCounted
## What comes at a player, in a save: raids and the attacks of factions,
## kraken waves, the guardians' return, and what its scouts know of the
## other bases. The random events are EventCodec's.


static func attack(x: AnnouncedAttack) -> Dictionary:
	return {
		"attackerId": x.attacker_id, "units": SaveValues.counts(x.units, UnitType.Value),
		"arrivalTurn": x.arrival_turn, "seed": x.fight_seed,
	}


static func read_attack(r: SaveReader, value: Variant) -> AnnouncedAttack:
	var m := r.object(value, "AnnouncedAttack")
	return AnnouncedAttack.new(
		r.text_at(m, "attackerId"), SaveCollections.counts_at(r, m, "units", UnitType.Value),
		r.int_at(m, "arrivalTurn"), r.int_at(m, "seed"),
	)


static func raid(x: RaidState) -> Dictionary:
	return {
		"noise": x.noise, "totalNoise": x.total_noise, "incoming": SaveValues.or_null(x.incoming, MapCodec.lair),
		"arrivalTurn": x.arrival_turn, "lostInARow": x.lost_in_a_row, "raidsRepelled": x.raids_repelled,
		"raidsLost": x.raids_lost, "attacks": SaveValues.list_of(x.attacks, attack),
		"kernelSiegeLostTurn": x.kernel_siege_lost_turn, "postAttackTurns": x.post_attack_turns.duplicate(),
		"kernelAttackTurns": x.kernel_attack_turns.duplicate(),
	}


static func read_raid(r: SaveReader, value: Variant) -> RaidState:
	var m := r.object(value, "RaidState")
	var attacks: Array[AnnouncedAttack] = []
	attacks.assign(SaveCollections.list_of(r, r.at(m, "attacks"), "attacks", read_attack))
	return RaidState.new(
		r.int_at(m, "noise"), r.int_at(m, "totalNoise"), MapCodec.read_lair_or_null(r, r.at(m, "incoming")),
		r.int_or_null_at(m, "arrivalTurn"), r.int_at(m, "lostInARow"), r.int_at(m, "raidsRepelled"),
		r.int_at(m, "raidsLost"), attacks, r.int_or_null_at(m, "kernelSiegeLostTurn"),
		SaveCollections.turns_by_id_at(r, m, "postAttackTurns"),
		SaveCollections.turns_by_id_at(r, m, "kernelAttackTurns"),
	)


static func volcano(x: VolcanoState) -> Dictionary:
	return {
		"incoming": SaveValues.or_null(x.incoming, MapCodec.lair), "arrivalTurn": x.arrival_turn,
		"wavesRepelled": x.waves_repelled, "levelsLost": x.levels_lost,
	}


static func read_volcano(r: SaveReader, value: Variant) -> VolcanoState:
	var m := r.object(value, "VolcanoState")
	return VolcanoState.new(
		MapCodec.read_lair_or_null(r, r.at(m, "incoming")), r.int_or_null_at(m, "arrivalTurn"),
		r.int_at(m, "wavesRepelled"), r.int_at(m, "levelsLost"),
	)


static func leviathan(x: LeviathanReturn) -> Dictionary:
	return {
		"postName": x.post_name, "level": x.level, "at": SaveValues.or_null(x.at, MapCodec.position),
		"strikeTurn": x.strike_turn, "over": x.over, "readyTurn": x.ready_turn,
	}


static func read_leviathan(r: SaveReader, value: Variant) -> LeviathanReturn:
	var m := r.object(value, "LeviathanReturn")
	return LeviathanReturn.new(
		r.text_or_null_at(m, "postName"), r.int_or_null_at(m, "level"),
		MapCodec.read_position_or_null(r, r.at(m, "at")), r.int_or_null_at(m, "strikeTurn"), r.bool_at(m, "over"),
		r.int_or_null_at(m, "readyTurn"),
	)


static func intel(x: BaseIntel) -> Dictionary:
	return {
		"turn": x.turn, "headquartersLevel": x.headquarters_level, "rampartLevel": x.rampart_level,
		"army": SaveValues.counts(x.army, UnitType.Value), "stocks": SaveValues.counts(x.stocks, ResourceType.Value),
	}


static func read_intel(r: SaveReader, value: Variant) -> BaseIntel:
	var m := r.object(value, "BaseIntel")
	return BaseIntel.new(
		r.int_at(m, "turn"), r.int_at(m, "headquartersLevel"), r.int_at(m, "rampartLevel"),
		SaveCollections.counts_at(r, m, "army", UnitType.Value),
		SaveCollections.counts_at(r, m, "stocks", ResourceType.Value),
	)
