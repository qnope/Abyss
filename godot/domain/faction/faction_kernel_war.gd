class_name FactionKernelWar
extends RefCounted
## lib/domain/faction/faction_kernel_war.dart: a faction that lays siege to
## the volcanic kernel another player holds, when the fighters it has on the
## volcano level beat the garrison and the magma rampart in the same share of
## rehearsals as for a base (FactionWar.planner). It only looks at a kernel
## its own fog has shown.
##
## A faction besieges a kernel held at KernelSiege.HOT_LEVEL or more with
## besiege_hot, before any base, and one below with besiege_cold; play keeps
## the plain rule, whatever the level, for the reference scripts
## (ContestMoves). None weighs a kernel its AttackCooldown still spares.
##
## The kernel of the human is not announced: the attack is resolved at once,
## kept in the history and reported at the end of the turn.


## Attacks the held kernel it has seen, whatever its level; returns whether
## it attacked. `planner` null is FactionWar.planner().
static func play(turn: ScriptTurn, planner: ArmyPlanner = null) -> bool:
	return _besiege(turn, planner if planner != null else FactionWar.planner(), null)


## Attacks the held kernel it has seen below KernelSiege.HOT_LEVEL; returns
## whether it attacked.
static func besiege_cold(turn: ScriptTurn, planner: ArmyPlanner) -> bool:
	return _besiege(turn, planner, false)


## Attacks the held kernel it has seen at KernelSiege.HOT_LEVEL or more,
## unless its holder already lost KernelSiege.won_per_turn sieges this turn,
## with the planner of KernelSiege.planner_for; returns whether it attacked.
static func besiege_hot(turn: ScriptTurn, planner: ArmyPlanner) -> bool:
	return _besiege(turn, planner, true)


## With `hot` null, any level and the plain `planner`; else a bool.
static func _besiege(turn: ScriptTurn, planner: ArmyPlanner, hot: Variant) -> bool:
	var me := turn.player
	var army := FactionWar.fighters_on(me, KernelGarrison.VOLCANO_LEVEL)
	if army.is_empty():
		return false
	var at := seen_kernel(turn)
	var owner := _holder_at(turn, at) if at != null else null
	if at == null or owner == null:
		return false
	var level := KernelGarrison.kernel_level_of(owner)
	if hot != null and KernelSiege.is_hot(level) != hot:
		return false
	if hot == true and KernelSiege.is_capped(turn.game, owner):
		return false
	if AttackCooldown.on_kernel(turn.game, me, owner):
		return false
	var judge := KernelSiege.planner_for(planner, level) if hot == true else planner
	var defence := func() -> Array[Combatant]: return BaseDefence.kernel(owner).side
	if not judge.wins(army, defence, FightMonsterHelpers.unit_boost_of(me, true)):
		return false
	return turn.try_perform(AttackHeldKernelAction.new(at.x, at.y, army, turn.random()))


## The other living player holding the kernel the fog of `turn`'s player has
## shown, if any.
static func holder_of(turn: ScriptTurn) -> Player:
	var at := seen_kernel(turn)
	return null if at == null else _holder_at(turn, at)


static func _holder_at(turn: ScriptTurn, at: GridPosition) -> Player:
	var map: GameMap = turn.game.levels[KernelGarrison.VOLCANO_LEVEL]
	var collected_by: Variant = map.cell_at(at.x, at.y).collected_by
	var owner: Player = turn.game.players.get(collected_by) if collected_by != null else null
	if owner == null or owner.id == turn.player.id or owner.has_fallen():
		return null
	return owner


## The anchor of the kernel when the fog of `turn`'s player has shown it.
## The volcano is always laid at the centre of its level
## (VolcanicKernelPlacer.place) and revealed whole, so only its anchor is
## looked up (VolcanoFootprint.anchor_of checks it is the kernel).
static func seen_kernel(turn: ScriptTurn) -> GridPosition:
	var map: GameMap = turn.game.levels.get(KernelGarrison.VOLCANO_LEVEL)
	if map == null:
		return null
	var at := VolcanoFootprint.anchor_of(
		map, DartMath.trunc_div(map.width, 2), DartMath.trunc_div(map.height, 2)
	)
	if at == null:
		return null
	var seen := GridPosition.keys(turn.player.revealed_cells_on_level(KernelGarrison.VOLCANO_LEVEL))
	return at if seen.has(at.key()) else null
