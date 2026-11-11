class_name FightSnapshots
extends RefCounted
## lib/domain/reference/snapshots/fight_snapshots.dart: snapshots of a fight
## as the history keeps it.


## The `role` and `family` of a Combatant are fields here, set by `_init`
## from its type: Dart computes them (`late final`) and saves neither.
static func combatant() -> ClassSnapshot:
	return ClassSnapshot.new("Combatant", {
		"side": func(c: Combatant, _ids: PlayerIds) -> Variant: return SnapshotValues.name(CombatSide.Value, c.side),
		"typeKey": func(c: Combatant, _ids: PlayerIds) -> Variant: return c.type_key,
		"maxHp": func(c: Combatant, _ids: PlayerIds) -> Variant: return c.max_hp,
		"atk": func(c: Combatant, _ids: PlayerIds) -> Variant: return c.atk,
		"def": func(c: Combatant, _ids: PlayerIds) -> Variant: return c.def,
		"currentHp": func(c: Combatant, _ids: PlayerIds) -> Variant: return c.current_hp,
		"isBoss": func(c: Combatant, _ids: PlayerIds) -> Variant: return c.is_boss,
	}, {}, {
		"role": "derived from the type of the combatant when it is built; Dart computes it and saves nothing",
		"family": "derived from the type of the combatant when it is built; Dart computes it and saves nothing",
	})


static func turn() -> ClassSnapshot:
	return ClassSnapshot.new("FightTurnSummary", {
		"turnNumber": func(t: FightTurnSummary, _ids: PlayerIds) -> Variant: return t.turn_number,
		"attacksPlayed": func(t: FightTurnSummary, _ids: PlayerIds) -> Variant: return t.attacks_played,
		"critCount": func(t: FightTurnSummary, _ids: PlayerIds) -> Variant: return t.crit_count,
		"damageDealtByPlayer": func(t: FightTurnSummary, _ids: PlayerIds) -> Variant: return t.damage_dealt_by_player,
		"damageDealtByMonster": func(t: FightTurnSummary, _ids: PlayerIds) -> Variant: return t.damage_dealt_by_monster,
		"playerAliveAtEnd": func(t: FightTurnSummary, _ids: PlayerIds) -> Variant: return t.player_alive_at_end,
		"monsterAliveAtEnd": func(t: FightTurnSummary, _ids: PlayerIds) -> Variant: return t.monster_alive_at_end,
		"playerHpAtEnd": func(t: FightTurnSummary, _ids: PlayerIds) -> Variant: return t.player_hp_at_end,
		"monsterHpAtEnd": func(t: FightTurnSummary, _ids: PlayerIds) -> Variant: return t.monster_hp_at_end,
	})


static func result() -> ClassSnapshot:
	var turns := turn()
	var combatants := combatant()
	return ClassSnapshot.new("FightResult", {
		"winner": func(f: FightResult, _ids: PlayerIds) -> Variant: return SnapshotValues.name(CombatSide.Value, f.winner),
		"turnCount": func(f: FightResult, _ids: PlayerIds) -> Variant: return f.turn_count,
		"turnSummaries": func(f: FightResult, ids: PlayerIds) -> Variant: return turns.list_of(f.turn_summaries, ids),
		"initialPlayerCombatants": func(f: FightResult, ids: PlayerIds) -> Variant:
			return combatants.list_of(f.initial_player_combatants, ids),
		"finalPlayerCombatants": func(f: FightResult, ids: PlayerIds) -> Variant:
			return combatants.list_of(f.final_player_combatants, ids),
		"initialMonsterCount": func(f: FightResult, _ids: PlayerIds) -> Variant: return f.initial_monster_count,
		"finalMonsterCount": func(f: FightResult, _ids: PlayerIds) -> Variant: return f.final_monster_count,
	})
