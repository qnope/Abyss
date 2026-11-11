class_name ConquestStrategy
extends GameScript
## lib/domain/script/strategies/conquest_strategy.dart: "Conquête", plays a
## whole game the way a careful player would, from the first building to the
## volcanic kernel at level 10.
##
## It answers the random events, holds every announced raid, clears the
## lairs it surely beats, explores, takes a Faille, a Cheminée and the
## kernel, and grows the base with what is left.

const GOALS: Array[BuildingType.Value] = [
	BuildingType.Value.VOLCANIC_KERNEL,
	BuildingType.Value.PRESSURE_CAPSULE,
	BuildingType.Value.DESCENT_MODULE,
]

const GROWTH_ORDER: Array[BuildingType.Value] = [
	BuildingType.Value.HEADQUARTERS, BuildingType.Value.SOLAR_PANEL, BuildingType.Value.ALGAE_FARM,
	BuildingType.Value.CORAL_MINE, BuildingType.Value.ORE_EXTRACTOR, BuildingType.Value.BARRACKS,
	BuildingType.Value.LABORATORY, BuildingType.Value.CORAL_CITADEL,
]

var planner: ArmyPlanner
## Share of the stocks the conquest may spend on recruits each turn.
var conquest_share: float
## Whether the home army clears the lairs it surely beats.
var hunts_lairs: bool
## Whether it recruits to hold the announced raids; without it, only the
## expedition force waiting at home defends the base.
var defends: bool
## Whether it keeps a garrison able to beat the kraken waves.
var guards_kernel: bool
## Whether it takes the posts and the kernel that others hold.
var contests: bool
## Whether it chases the wrecks whatever the noise they make.
var chases_wrecks: bool
## Whether it also clears lairs while a raid is announced, once the base is
## defended: a faction is nearly always under a raid.
var hunts_under_raid: bool
## The order in which it grows the base.
var growth: Array[BuildingType.Value]
## Scouts kept exploring the base level while it is not fully known.
var explorers: int
## Scouts an expedition keeps on the deepest level it reaches.
var deep_scouts: int
## Explorations a turn on levels 2 and 3.
var deep_explorers: int
## Whether scouts go down ahead of the army, ready or not.
var scouts_ahead: bool
## What the scouts of the base level add to a target while nothing is found
## yet, `(turn, target) -> float`; invalid, the default sends them away from
## the middle of the map.
var scout_bias: Callable
## Whether the volcano army is sized against a kernel held high by another.
var besieges_held_kernel: bool
## The research plan and the options of its choice nodes.
var research_plan: Array[TechBranch.Value]
var research_picks: Dictionary[TechBranch.Value, Array]
var _name: String


func _init(
	planner_: ArmyPlanner = null, conquest_share_ := 0.5, hunts_lairs_ := true, defends_ := true,
	guards_kernel_ := true, contests_ := true, chases_wrecks_ := false, hunts_under_raid_ := false,
	growth_: Array[BuildingType.Value] = GROWTH_ORDER, explorers_ := 2,
	deep_scouts_ := ConquestMoves.EXPEDITION_SCOUTS, deep_explorers_ := 2, scouts_ahead_ := false,
	scout_bias_ := Callable(), besieges_held_kernel_ := false,
	research_plan_: Array[TechBranch.Value] = GrowthMoves.RESEARCH_PLAN,
	research_picks_: Dictionary[TechBranch.Value, Array] = GrowthMoves.PICKS, name_ := "conquest",
) -> void:
	planner = planner_ if planner_ != null else ArmyPlanner.new()
	conquest_share = conquest_share_
	hunts_lairs = hunts_lairs_
	defends = defends_
	guards_kernel = guards_kernel_
	contests = contests_
	chases_wrecks = chases_wrecks_
	hunts_under_raid = hunts_under_raid_
	growth = growth_
	explorers = explorers_
	deep_scouts = deep_scouts_
	deep_explorers = deep_explorers_
	scouts_ahead = scouts_ahead_
	scout_bias = scout_bias_
	besieges_held_kernel = besieges_held_kernel_
	research_plan = research_plan_
	research_picks = research_picks_
	_name = name_


func name() -> String:
	return _name


func play_turn(turn: ScriptTurn) -> void:
	for level: int in turn.game.levels.keys():
		ExploreMoves.collect_revealed(turn, level)
	EventMoves.play_events(turn, planner, true, chases_wrecks)
	var alert := turn.player.raid_state.is_incoming()
	if alert and defends:
		BattleMoves.defend_base(turn, planner)
	if defends:
		BattleMoves.defend_attacks(turn, planner)
	for goal: BuildingType.Value in GOALS:
		turn.try_perform(UpgradeBuildingAction.new(goal))
	if guards_kernel:
		KernelGuardMoves.guard_kernel(turn, planner)
	GrowthMoves.research(turn, research_plan, research_picks)
	if not alert:
		ConquestMoves.advance_conquest(turn, planner, conquest_share, deep_scouts, besieges_held_kernel)
		if contests:
			ContestMoves.contest(turn)
		if hunts_lairs and not hunts_under_raid:
			BattleMoves.hunt_lairs(turn, planner)
	if hunts_lairs and hunts_under_raid:
		BattleMoves.hunt_lairs(turn, planner)
	if defends:
		LeviathanGuardMoves.guard_faille(turn)
	GrowthMoves.grow_in_order(turn, growth)
	ScoutMoves.scout(turn, explorers, deep_scouts, deep_explorers, scouts_ahead, scout_bias)
