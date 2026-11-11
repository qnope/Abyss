class_name FightCodec
extends RefCounted
## A fight as the history keeps it, in a save. The `role` and `family` of a
## combatant are not written: Dart computes them from its type and saves
## neither, and the constructor computes them again.


static func combatant(x: Combatant) -> Dictionary:
	return {
		"side": SaveValues.name(CombatSide.Value, x.side), "typeKey": x.type_key, "maxHp": x.max_hp,
		"atk": x.atk, "def": x.def, "currentHp": x.current_hp, "isBoss": x.is_boss,
	}


static func read_combatant(r: SaveReader, value: Variant) -> Combatant:
	var m := r.object(value, "Combatant")
	return Combatant.new(
		r.enum_at(m, "side", CombatSide.Value), r.text_at(m, "typeKey"), r.int_at(m, "maxHp"), r.int_at(m, "atk"),
		r.int_at(m, "def"), r.int_at(m, "currentHp"), r.bool_at(m, "isBoss"),
	)


static func turn(x: FightTurnSummary) -> Dictionary:
	return {
		"turnNumber": x.turn_number, "attacksPlayed": x.attacks_played, "critCount": x.crit_count,
		"damageDealtByPlayer": x.damage_dealt_by_player, "damageDealtByMonster": x.damage_dealt_by_monster,
		"playerAliveAtEnd": x.player_alive_at_end, "monsterAliveAtEnd": x.monster_alive_at_end,
		"playerHpAtEnd": x.player_hp_at_end, "monsterHpAtEnd": x.monster_hp_at_end,
	}


static func read_turn(r: SaveReader, value: Variant) -> FightTurnSummary:
	var m := r.object(value, "FightTurnSummary")
	return FightTurnSummary.new(
		r.int_at(m, "turnNumber"), r.int_at(m, "attacksPlayed"), r.int_at(m, "critCount"),
		r.int_at(m, "damageDealtByPlayer"), r.int_at(m, "damageDealtByMonster"), r.int_at(m, "playerAliveAtEnd"),
		r.int_at(m, "monsterAliveAtEnd"), r.int_at(m, "playerHpAtEnd"), r.int_at(m, "monsterHpAtEnd"),
	)


static func result(x: FightResult) -> Dictionary:
	return {
		"winner": SaveValues.name(CombatSide.Value, x.winner), "turnCount": x.turn_count,
		"turnSummaries": SaveValues.list_of(x.turn_summaries, turn),
		"initialPlayerCombatants": SaveValues.list_of(x.initial_player_combatants, combatant),
		"finalPlayerCombatants": SaveValues.list_of(x.final_player_combatants, combatant),
		"initialMonsterCount": x.initial_monster_count, "finalMonsterCount": x.final_monster_count,
	}


static func read_result(r: SaveReader, value: Variant) -> FightResult:
	var m := r.object(value, "FightResult")
	var turns: Array[FightTurnSummary] = []
	turns.assign(SaveCollections.list_of(r, r.at(m, "turnSummaries"), "turnSummaries", read_turn))
	return FightResult.new(
		r.enum_at(m, "winner", CombatSide.Value), r.int_at(m, "turnCount"), turns,
		_combatants(r, m, "initialPlayerCombatants"), _combatants(r, m, "finalPlayerCombatants"),
		r.int_at(m, "initialMonsterCount"), r.int_at(m, "finalMonsterCount"),
	)


static func _combatants(r: SaveReader, m: Dictionary, key: String) -> Array[Combatant]:
	var found: Array[Combatant] = []
	found.assign(SaveCollections.list_of(r, r.at(m, key), key, read_combatant))
	return found
