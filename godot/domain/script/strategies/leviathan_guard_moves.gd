class_name LeviathanGuardMoves
extends RefCounted
## lib/domain/script/strategies/leviathan_guard_moves.dart: holding the first
## Faille against the guardians that come back to it ("le Léviathan
## revient"), as a careful player does the turn they are announced: they
## strike at its end, against the units of the level below, and a descent
## through the Faille arrives at once. The Dart extension on ScriptTurn.
##
## Dart's constant `margin` is the function `margin()`.


## The Module and the units below are at stake: the guard is sized to win
## 95 % of 50 rehearsals; fewer let small guards through by luck.
static func margin() -> ArmyPlanner:
	return ArmyPlanner.new(50, 0.95)


## When the guardians strike the human's Faille at the end of this turn,
## sends down through it the smallest share of the home fighters that beats
## them with the fighters already below, and recruits what is missing with
## `share` of the stocks at most; the recruits always go down whole, they
## were raised for it. While the base itself awaits a raid or an attack, only
## what it can spare goes down, else only fresh recruits. A Faille that
## cannot be held keeps its army home. `planner` null is margin().
static func guard_faille(turn: ScriptTurn, planner: ArmyPlanner = null, share := 1.0) -> void:
	var judge := planner if planner != null else margin()
	var game := turn.game
	var player := turn.player
	var strike := LeviathanResolver.announced_now(game)
	if strike == null or player.id != game.human_player_id:
		return
	if not PostTakeover.passage_works(player, TransitionBaseType.Value.FAILLE):
		return
	var level := strike.level
	var below := ExpeditionMoves.fighters_on(turn, strike.defending_level())
	var alert := player.raid_state.is_incoming() or not player.raid_state.attacks.is_empty()
	var before := _counts(player, level)
	var recruits: Dictionary[UnitType.Value, int] = {}
	var force := _force(game)
	var boost := TechEffects.of(player).unit_boost()
	var homes: Array[Dictionary] = [_spare(turn, level)]
	if alert:
		homes.append({} as Dictionary[UnitType.Value, int])
	for home: Dictionary[UnitType.Value, int] in homes:
		var k: Variant = _smallest(judge, _sum(below, recruits), home, force, boost)
		if k == null:
			RecruitMoves.top_up(
				turn, _sum(_sum(below, recruits), home), force, KernelGuardMoves.GUARD_MIXES, judge,
				boost, Callable(), false, share
			)
			recruits = _recruited(before, _counts(player, level))
			k = _smallest(judge, _sum(below, recruits), home, force, boost)
		if k == null:
			continue
		var smallest: int = k
		var sent := _sum(recruits, _part(home, smallest))
		if not alert or home.is_empty() or BattleMoves.holds_without(turn, sent, ArmyPlanner.new()):
			ExpeditionMoves.descend(turn, level, sent)
			return


## The guardians, on the monsters' side of a rehearsal.
static func _force(game: Game) -> Callable:
	return func() -> Array[Combatant]:
		var side: Array[Combatant] = []
		for c: Combatant in LeviathanForce.of(game):
			side.append(Combatant.new(CombatSide.Value.MONSTER, c.type_key, c.max_hp, c.atk, c.def, null, c.is_boss))
		return side


static func _smallest(
	planner: ArmyPlanner, below: Dictionary[UnitType.Value, int], spare: Dictionary[UnitType.Value, int],
	force: Callable, boost: UnitBoost,
) -> Variant:
	var army_of := func(k: int) -> Dictionary[UnitType.Value, int]: return _sum(below, _part(spare, k))
	return planner.smallest_winning(20, army_of, force, boost)


## The fighters of `level` the base can spare: the admiral leads the
## assaults, he stays.
static func _spare(turn: ScriptTurn, level: int) -> Dictionary[UnitType.Value, int]:
	var spare := ExpeditionMoves.fighters_on(turn, level)
	spare.erase(UnitType.Value.ABYSS_ADMIRAL)
	return spare


static func _counts(player: Player, level: int) -> Dictionary[UnitType.Value, int]:
	var counts: Dictionary[UnitType.Value, int] = {}
	var units := player.units_on_level(level)
	for t: UnitType.Value in units:
		counts[t] = units[t].count
	return counts


static func _recruited(
	before: Dictionary[UnitType.Value, int], after: Dictionary[UnitType.Value, int]
) -> Dictionary[UnitType.Value, int]:
	var fresh: Dictionary[UnitType.Value, int] = {}
	for t: UnitType.Value in after:
		if after[t] > before.get(t, 0):
			fresh[t] = after[t] - before.get(t, 0)
	return fresh


static func _part(units: Dictionary[UnitType.Value, int], k: int) -> Dictionary[UnitType.Value, int]:
	var part: Dictionary[UnitType.Value, int] = {}
	for t: UnitType.Value in units:
		part[t] = ceili(DartMath.quotient(units[t] * k, 20))
	return part


static func _sum(
	a: Dictionary[UnitType.Value, int], b: Dictionary[UnitType.Value, int]
) -> Dictionary[UnitType.Value, int]:
	var total: Dictionary[UnitType.Value, int] = a.duplicate()
	for t: UnitType.Value in b:
		total[t] = a.get(t, 0) + b[t]
	return total
