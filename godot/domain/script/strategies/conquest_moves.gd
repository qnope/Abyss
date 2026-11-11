class_name ConquestMoves
extends RefCounted
## lib/domain/script/strategies/conquest_moves.dart: the road to the volcano,
## a Faille on the base level, a Cheminée on level 2, then the volcanic
## kernel at the centre of level 3. The Dart extension on ScriptTurn: each
## function takes the turn first. An enemy given as an invalid Callable is
## Dart's null.

const _ADMIRAL := UnitType.Value.ABYSS_ADMIRAL
const _SCOUT := UnitType.Value.SCOUT

## Units of an assault force: Gardiens to hold, hitters to break (mixes of
## RecruitMoves).
const ASSAULT_MIXES: Array[Dictionary] = [
	{UnitType.Value.GUARDIAN: 1, UnitType.Value.DOME_BREAKER: 1},
	{UnitType.Value.GUARDIAN: 1, UnitType.Value.HARPOONIST: 1},
	{UnitType.Value.HARPOONIST: 1},
]

## Scouts an expedition takes down to explore the level below.
const EXPEDITION_SCOUTS := 4


## Plays the next step of the conquest, with `share` of the stocks at most
## for the recruits it needs and `scouts` going down with the army. With
## `besieges_held_kernel` (factions only), the army of the volcano level is
## sized against a kernel another player holds high
## (SiegeMoves.hot_kernel_defence) instead of its starting guardians.
static func advance_conquest(
	turn: ScriptTurn, planner: ArmyPlanner, share := 0.5, scouts := EXPEDITION_SCOUTS,
	besieges_held_kernel := false,
) -> void:
	if turn.game.is_volcanic_kernel_captured_by(turn.player.id):
		return
	if _built(turn, BuildingType.Value.PRESSURE_CAPSULE):
		var kernel := ExpeditionMoves.open_kernel(turn)
		if kernel != null and ExpeditionMoves.assault(turn, 3, kernel, planner):
			return
		var enemy := Callable()
		if besieges_held_kernel and kernel == null:
			enemy = SiegeMoves.hot_kernel_defence(turn)
		_bring_down(turn, planner, null, [1, 2], share, scouts, enemy)
	elif _built(turn, BuildingType.Value.DESCENT_MODULE):
		if ExpeditionMoves.own_base(turn, 2) != null:
			return
		var cheminee := ExpeditionMoves.open_base(turn, 2)
		if cheminee != null and ExpeditionMoves.assault(turn, 2, cheminee, planner):
			return
		_bring_down(turn, planner, TransitionBaseType.Value.CHEMINEE, [1], share, scouts)
	elif ExpeditionMoves.own_base(turn, 1) == null:
		var faille := ExpeditionMoves.open_base(turn, 1)
		if faille == null or ExpeditionMoves.assault(turn, 1, faille, planner):
			return
		_prepare(turn, planner, TransitionBaseType.Value.FAILLE, {}, share)


## Sends the expedition down `path` (levels to leave, in order) once the
## forces there and below beat the guardians of `type` (the kernel when
## null), or `enemy` without admiral when valid, with up to `wanted` scouts
## below; recruits towards it meanwhile. The whole `path` is walked in the
## same turn.
static func _bring_down(
	turn: ScriptTurn, planner: ArmyPlanner, type: Variant, path: Array[int], share: float,
	wanted: int, enemy := Callable(),
) -> void:
	var player := turn.player
	var bottom: int = path.back() + 1
	var below: Dictionary[UnitType.Value, int] = {}
	for level: int in range(path[0] + 1, bottom + 1):
		var fighters := ExpeditionMoves.fighters_on(turn, level)
		for t: UnitType.Value in fighters:
			below[t] = below.get(t, 0) + fighters[t]
	if enemy.is_valid():
		below.erase(_ADMIRAL)
	var scouts_below := Unit.count_in(player.units_on_level(bottom), _SCOUT)
	var scouts_home := Unit.count_in(player.units_on_level(1), _SCOUT)
	var scouts := clampi(wanted - scouts_below, 0, scouts_home)
	var sent: Dictionary[UnitType.Value, int]
	if ExpeditionMoves.ready_for(turn, type, bottom, planner, {}, enemy):
		if scouts_below > 1:
			return
		sent = {_SCOUT: scouts}
	elif ExpeditionMoves.ready_for(turn, type, 1, planner, below, enemy):
		sent = _part(turn, planner, type, below, enemy)
		sent[_SCOUT] = scouts
	else:
		_prepare(turn, planner, type, below, share, enemy)
		return
	if not ExpeditionMoves.descend(turn, 1, sent):
		return
	for level: int in path.slice(1):
		ExpeditionMoves.descend(turn, level, player.unit_counts_on_level(level))


## Smallest share of the home fighters that, joined to `below`, beats the
## guardians of `type`, or `enemy` without admiral when valid.
static func _part(
	turn: ScriptTurn, planner: ArmyPlanner, type: Variant, below: Dictionary[UnitType.Value, int],
	enemy: Callable,
) -> Dictionary[UnitType.Value, int]:
	var home := ExpeditionMoves.fighters_on(turn, 1)
	if enemy.is_valid():
		home.erase(_ADMIRAL)
	var admiral_below: bool = below.get(_ADMIRAL, 0) > 0
	var part := func(k: int) -> Dictionary[UnitType.Value, int]:
		var army: Dictionary[UnitType.Value, int] = {}
		for t: UnitType.Value in home:
			if t == _ADMIRAL:
				army[t] = 0 if admiral_below else 1
			else:
				army[t] = ceili(DartMath.quotient(home[t] * k, 20))
		return army
	var with_below := func(k: int) -> Dictionary[UnitType.Value, int]:
		var share_k: Dictionary[UnitType.Value, int] = part.call(k)
		var army: Dictionary[UnitType.Value, int] = {}
		for t: UnitType.Value in UnitType.Value.values():
			army[t] = share_k.get(t, 0) + below.get(t, 0)
		return army
	var foe := enemy if enemy.is_valid() else ExpeditionMoves.guardians_of(type)
	var k: Variant = planner.smallest_winning(
		20, with_below, foe, ExpeditionMoves.attack_boost(turn), Callable(), not enemy.is_valid()
	)
	return part.call(20 if k == null else k)


## Recruits an admiral if the force lacks one, then the cheapest units that
## let the home army, with `extra`, beat the guardians of `type`; against
## `enemy`, when valid, no admiral is needed.
static func _prepare(
	turn: ScriptTurn, planner: ArmyPlanner, type: Variant, extra: Dictionary[UnitType.Value, int],
	share: float, enemy := Callable(),
) -> void:
	var base := ExpeditionMoves.fighters_on(turn, 1)
	for t: UnitType.Value in extra:
		base[t] = base.get(t, 0) + extra[t]
	if enemy.is_valid():
		base.erase(_ADMIRAL)
	elif base.get(_ADMIRAL, 0) <= 0:
		turn.try_perform(RecruitUnitAction.new(_ADMIRAL, 1))
		return
	var foe := enemy if enemy.is_valid() else ExpeditionMoves.guardians_of(type)
	RecruitMoves.top_up(
		turn, base, foe, ASSAULT_MIXES, planner, ExpeditionMoves.attack_boost(turn), Callable(),
		not enemy.is_valid(), share
	)


static func _built(turn: ScriptTurn, type: BuildingType.Value) -> bool:
	return turn.player.buildings[type].level > 0
