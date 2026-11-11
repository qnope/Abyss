class_name ScoutMoves
extends RefCounted
## lib/domain/script/strategies/scout_moves.dart: scouting of the conquest,
## scouts recruited at home, sent over each level towards what the road to
## the volcano still has to find. The Dart extension on ScriptTurn: each
## function takes the turn first.


## Scouts the base level should hold: `explorers` while it is not fully
## known, plus, while on the expedition, the `deep_scouts` it takes down
## with the army. With `scouts_ahead`, the scouts go down on their own:
## only those missing below are wanted.
static func scouts_wanted(turn: ScriptTurn, explorers: int, deep_scouts: int, scouts_ahead := false) -> int:
	var deep := 0
	if _on_expedition(turn):
		deep = ScoutDescentMoves.scouts_missing_below(turn, deep_scouts) if scouts_ahead else deep_scouts
	return (0 if ExploreMoves.fully_explored(turn, 1) else explorers) + deep


## Whether a Faille is held and the kernel not taken yet.
static func _on_expedition(turn: ScriptTurn) -> bool:
	return ExpeditionMoves.own_base(turn, 1) != null and not turn.game.is_volcanic_kernel_captured_by(turn.player.id)


## Recruits the scouts it lacks, explores the base level with `explorers`
## of them and levels 2 and 3 with `deep_explorers` each.
##
## Until a Faille is found, `bias` (a (ScriptTurn, GridPosition) -> float,
## not valid for none) steers the base level (by default away from the
## middle); level 2 looks away from the middle until a Cheminée is seen,
## level 3 towards it until the volcano is seen. With `scouts_ahead`, while
## on the expedition, scouts go down to the deepest level it reaches until
## `deep_scouts` stand there, army or not.
static func scout(
	turn: ScriptTurn,
	explorers: int,
	deep_scouts := ConquestMoves.EXPEDITION_SCOUTS,
	deep_explorers := 2,
	scouts_ahead := false,
	bias := Callable(),
) -> void:
	var expedition := _on_expedition(turn)
	var reserve := deep_scouts if expedition and not scouts_ahead else 0
	var home := _scouts_on(turn, 1)
	var wanted := scouts_wanted(turn, explorers, deep_scouts, scouts_ahead)
	if home < wanted:
		turn.try_perform(RecruitUnitAction.new(UnitType.Value.SCOUT, wanted - home))
	# The fog only moves at the end of the turn: what is seen holds for every
	# target of the turn.
	var found := ExpeditionMoves.own_base(turn, 1) != null or ExpeditionMoves.open_base(turn, 1) != null
	var off1 := _from_centre_of(turn, 1)
	ExploreMoves.explore(turn, 1, mini(explorers, _scouts_on(turn, 1) - reserve), func(p: GridPosition) -> float:
		if found:
			return 0.0
		if bias.is_valid():
			return bias.call(turn, p)
		return 0.3 * off1.call(p))
	if scouts_ahead and expedition:
		ScoutDescentMoves.send_scouts_down(turn, deep_scouts)
	var cheminee_seen := ExpeditionMoves.open_base(turn, 2) != null
	var off2 := _from_centre_of(turn, 2)
	ExploreMoves.explore(turn, 2, deep_explorers, func(p: GridPosition) -> float:
		return 0.0 if cheminee_seen else 0.5 * off2.call(p))
	var kernel_seen := ExpeditionMoves.kernel_seen(turn)
	var off3 := _from_centre_of(turn, 3)
	ExploreMoves.explore(turn, 3, deep_explorers, func(p: GridPosition) -> float:
		return 0.0 if kernel_seen else -1.0 * off3.call(p))


## Distance of `p` to the middle of the `level` map, where the volcano
## stands on level 3.
static func from_centre(turn: ScriptTurn, level: int, p: GridPosition) -> int:
	return _from_centre_of(turn, level).call(p)


## Distance to the middle of the `level` map, its centre read once.
static func _from_centre_of(turn: ScriptTurn, level: int) -> Callable:
	var map: GameMap = turn.game.levels.get(level)
	var cx := 10 if map == null else DartMath.trunc_div(map.width, 2)
	var cy := 10 if map == null else DartMath.trunc_div(map.height, 2)
	return func(p: GridPosition) -> int:
		return maxi(absi(p.x - cx), absi(p.y - cy))


static func _scouts_on(turn: ScriptTurn, level: int) -> int:
	var scouts: Unit = turn.player.units_on_level(level).get(UnitType.Value.SCOUT)
	return 0 if scouts == null else scouts.count
