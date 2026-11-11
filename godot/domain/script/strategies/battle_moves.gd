class_name BattleMoves
extends RefCounted
## lib/domain/script/strategies/battle_moves.dart: fights on the base level,
## holding raids and clearing monster lairs. The Dart extension on
## ScriptTurn: each function takes the turn first.

## Units that hold the base: one Gardien for two Harponneurs once the
## barracks trains Gardiens, Harponneurs before (mixes of RecruitMoves).
const DEFENCE_MIXES: Array[Dictionary] = [
	{UnitType.Value.GUARDIAN: 1, UnitType.Value.HARPOONIST: 2},
	{UnitType.Value.GUARDIAN: 1, UnitType.Value.HARPOONIST: 1},
	{UnitType.Value.HARPOONIST: 1},
]


## Recruits what the base needs to beat the announced raid, with `share` of
## the stocks at most. Returns whether it should hold.
static func defend_base(turn: ScriptTurn, planner: ArmyPlanner, share := 1.0) -> bool:
	var wave := turn.player.raid_state.incoming
	if wave == null:
		return true
	return RecruitMoves.top_up(
		turn, RaidBattle.defenders_of(turn.player), _monsters(wave), DEFENCE_MIXES, planner,
		ExpeditionMoves.defence_boost(turn), _rampart(turn), false, share,
	)


## Recruits what the base needs to beat the attacks of factions it is warned
## of, with `share` of the stocks at most. Returns whether it should hold
## them all.
static func defend_attacks(turn: ScriptTurn, planner: ArmyPlanner, share := 1.0) -> bool:
	var holds_all := true
	for attack: AnnouncedAttack in turn.player.raid_state.attacks:
		holds_all = RecruitMoves.top_up(
			turn, RaidBattle.defenders_of(turn.player), _attackers(attack), DEFENCE_MIXES, planner,
			ExpeditionMoves.defence_boost(turn), _rampart(turn), false, share,
		) and holds_all
	return holds_all


## Whether the units on the base level and the rampart beat `wave`, with
## `planner`'s confidence, as they stand now.
static func holds(turn: ScriptTurn, wave: MonsterLair, planner: ArmyPlanner) -> bool:
	return planner.wins(
		RaidBattle.defenders_of(turn.player), _monsters(wave), ExpeditionMoves.defence_boost(turn), _rampart(turn)
	)


## Whether the base still beats the announced raid and every attack it is
## warned of, with `planner`'s confidence, once `away` has left it.
static func holds_without(turn: ScriptTurn, away: Dictionary[UnitType.Value, int], planner: ArmyPlanner) -> bool:
	var defenders := RaidBattle.defenders_of(turn.player)
	var left: Dictionary[UnitType.Value, int] = {}
	for t: UnitType.Value in defenders:
		left[t] = defenders[t] - away.get(t, 0)
	var enemies: Array[Callable] = []
	var wave := turn.player.raid_state.incoming
	if wave != null:
		enemies.append(_monsters(wave))
	for a: AnnouncedAttack in turn.player.raid_state.attacks:
		enemies.append(_attackers(a))
	for enemy: Callable in enemies:
		if not planner.wins(left, enemy, ExpeditionMoves.defence_boost(turn), _rampart(turn)):
			return false
	return true


## The Coral Citadel rampart that backs the base, not valid when unbuilt.
static func _rampart(turn: ScriptTurn) -> Callable:
	var buildings := turn.player.buildings
	if CoralCitadelRampart.combatant_of(buildings) == null:
		return Callable()
	return func() -> Array[Combatant]:
		return [CoralCitadelRampart.combatant_of(buildings)]


## Clears the revealed lairs of the base level that a share of the home army
## beats with `planner`'s confidence.
static func hunt_lairs(turn: ScriptTurn, planner: ArmyPlanner) -> void:
	var lairs := ExploreMoves.revealed_where(turn, 1, func(c: MapCell) -> bool:
		return c.content == CellContentType.Value.MONSTER_LAIR and not c.is_collected() and c.lair != null)
	for p: GridPosition in lairs:
		var lair := turn.game.levels[1].cell_at(p.x, p.y).lair
		var home := ExpeditionMoves.fighters_on(turn, 1)
		home.erase(UnitType.Value.ABYSS_ADMIRAL)
		if home.is_empty():
			return
		var share := func(k: int) -> Dictionary[UnitType.Value, int]:
			var army: Dictionary[UnitType.Value, int] = {}
			for t: UnitType.Value in home:
				army[t] = ceili(DartMath.quotient(home[t] * k, 20))
			return army
		var found: Variant = planner.smallest_winning(20, share, _monsters(lair), ExpeditionMoves.attack_boost(turn))
		if found == null:
			continue
		var k: int = found
		var army: Dictionary[UnitType.Value, int] = share.call(k)
		turn.try_perform(FightMonsterAction.new(p.x, p.y, 1, army, turn.random()))


static func _monsters(wave: MonsterLair) -> Callable:
	return func() -> Array[Combatant]:
		return CombatantBuilder.monster_combatants_from(wave)


static func _attackers(attack: AnnouncedAttack) -> Callable:
	return func() -> Array[Combatant]:
		return CombatantBuilder.player_combatants_from(attack.units, null, CombatSide.Value.MONSTER)
