class_name ExpeditionMoves
extends RefCounted
## lib/domain/script/strategies/expedition_moves.dart: moves of the
## conquest, assaulting transition bases and the volcanic kernel, and taking
## the army down through captured bases. The Dart extension on ScriptTurn:
## each function takes the turn first.


## Boost of the army when it attacks.
static func attack_boost(turn: ScriptTurn) -> UnitBoost:
	return TechEffects.of(turn.player).unit_boost(true)


## Boost of the army when it guards the base.
static func defence_boost(turn: ScriptTurn) -> UnitBoost:
	return TechEffects.of(turn.player).unit_boost(false, true)


## Revealed transition base of `level` not captured yet, or null.
static func open_base(turn: ScriptTurn, level: int) -> GridPosition:
	return _first(ExploreMoves.revealed_where(turn, level, func(c: MapCell) -> bool:
		return c.content == CellContentType.Value.TRANSITION_BASE and c.transition_base != null \
			and not c.transition_base.is_captured()))


## Transition base of `level` the player holds, or null.
static func own_base(turn: ScriptTurn, level: int) -> GridPosition:
	var id := turn.player.id
	return _first(ExploreMoves.revealed_where(turn, level, func(c: MapCell) -> bool:
		return c.transition_base != null and c.transition_base.captured_by == id))


## Revealed volcanic kernel not captured yet, or null.
static func open_kernel(turn: ScriptTurn) -> GridPosition:
	return _first(ExploreMoves.revealed_where(turn, 3, func(c: MapCell) -> bool:
		return c.content == CellContentType.Value.VOLCANIC_KERNEL and not c.is_collected()))


## Whether the fog shows a cell of the volcanic kernel, held or not.
static func kernel_seen(turn: ScriptTurn) -> bool:
	var map: GameMap = turn.game.levels.get(3)
	if map == null:
		return false
	for p: GridPosition in turn.player.revealed_cells_on_level(3):
		if map.cell_at(p.x, p.y).content == CellContentType.Value.VOLCANIC_KERNEL:
			return true
	return false


## Fighting units of `level` (scouts aside, they only explore).
static func fighters_on(turn: ScriptTurn, level: int) -> Dictionary[UnitType.Value, int]:
	var fighters: Dictionary[UnitType.Value, int] = {}
	var units := turn.player.units_on_level(level)
	for type: UnitType.Value in units:
		if type != UnitType.Value.SCOUT and units[type].count > 0:
			fighters[type] = units[type].count
	return fighters


## Assaults the guardians at `p` with the smallest share of the fighters of
## `level` that `planner` judges a win, the admiral leading; returns whether
## the assault was made.
static func assault(turn: ScriptTurn, level: int, p: GridPosition, planner: ArmyPlanner) -> bool:
	var cell: MapCell = turn.game.levels[level].cell_at(p.x, p.y)
	var kernel := cell.content == CellContentType.Value.VOLCANIC_KERNEL
	var enemy := guardians_of(null if kernel else cell.transition_base.type)
	var all := fighters_on(turn, level)
	if all.get(UnitType.Value.ABYSS_ADMIRAL, 0) <= 0:
		return false
	var share := func(k: int) -> Dictionary[UnitType.Value, int]:
		var army: Dictionary[UnitType.Value, int] = {}
		for t: UnitType.Value in all:
			army[t] = 1 if t == UnitType.Value.ABYSS_ADMIRAL else ceili(DartMath.quotient(all[t] * k, 20))
		return army
	var k: Variant = planner.smallest_winning(20, share, enemy, attack_boost(turn), Callable(), true)
	if k == null:
		return false
	var army: Dictionary[UnitType.Value, int] = share.call(k)
	if kernel:
		return turn.try_perform(AttackVolcanicKernelAction.new(p.x, p.y, level, army, turn.random()))
	return turn.try_perform(AttackTransitionBaseAction.new(p.x, p.y, level, army, turn.random()))


## Whether the fighters of `level` would beat the guardians of `type` (a
## TransitionBaseType.Value), or of the volcanic kernel when `type` is null;
## or `enemy`, when valid, without their admiral (a siege does not take it).
static func ready_for(
	turn: ScriptTurn,
	type: Variant,
	level: int,
	planner: ArmyPlanner,
	extra: Dictionary[UnitType.Value, int] = {},
	enemy := Callable(),
) -> bool:
	var army := fighters_on(turn, level)
	for t: UnitType.Value in extra:
		army[t] = army.get(t, 0) + extra[t]
	if enemy.is_valid():
		army.erase(UnitType.Value.ABYSS_ADMIRAL)
		return not army.is_empty() and planner.wins(army, enemy, attack_boost(turn))
	if army.get(UnitType.Value.ABYSS_ADMIRAL, 0) <= 0:
		return false
	return planner.wins(army, guardians_of(type), attack_boost(turn), Callable(), true)


## The guardians of a transition base of `type` (a TransitionBaseType.Value),
## or of the volcanic kernel when `type` is null.
static func guardians_of(type: Variant) -> Callable:
	if type == null:
		return GuardianFactory.for_volcanic_kernel
	var post: TransitionBaseType.Value = type
	return func() -> Array[Combatant]:
		return GuardianFactory.for_type(post)


## Takes `units` of `from_level` down through the player's base there.
static func descend(turn: ScriptTurn, from_level: int, units: Dictionary[UnitType.Value, int]) -> bool:
	var via := own_base(turn, from_level)
	if via == null:
		return false
	var sent: Dictionary[UnitType.Value, int] = {}
	for t: UnitType.Value in units:
		if units[t] > 0:
			sent[t] = units[t]
	if sent.is_empty():
		return false
	return turn.try_perform(DescendAction.new(via.x, via.y, from_level, sent, turn.random()))


static func _first(cells: Array[GridPosition]) -> GridPosition:
	return null if cells.is_empty() else cells[0]
