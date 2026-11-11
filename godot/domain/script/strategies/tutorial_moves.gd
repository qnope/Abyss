class_name TutorialMoves
extends RefCounted
## lib/domain/script/strategies/tutorial_moves.dart: what a newcomer does
## when the guide of the first chapter gives one objective at a time,
## exactly what it asks, nothing more. The Dart extension on ScriptTurn:
## each function takes the turn first.

const Id := ObjectiveId.Value
const Type := BuildingType.Value
## Scouts the guide asks for in its sixth objective.
const TUTORIAL_SCOUTS := 2


## The objective of the first chapter the guide gives now: the first one
## not completed, null once all are or once a raid was fought.
static func tutorial_step(turn: ScriptTurn) -> Objective:
	var raids := turn.player.raid_state
	if raids.raids_repelled + raids.raids_lost > 0:
		return null
	var state := ObjectiveMigration.state_of(turn.game, turn.player)
	for objective: Objective in InstallationObjectives.installation_objectives():
		if not state.is_completed(objective.id):
			return objective
	return null


## Plays what objective `id` of the first chapter asks for. The last one,
## the first raid, only waits for the raid.
static func follow_step(turn: ScriptTurn, id: Id) -> void:
	match id:
		Id.HQ_LEVEL_1:
			_raise(turn, Type.HEADQUARTERS, 1)
		Id.ALGAE_FARM:
			_raise(turn, Type.ALGAE_FARM, 1)
		Id.MINES:
			_raise(turn, Type.CORAL_MINE, 1)
			_raise(turn, Type.ORE_EXTRACTOR, 1)
		Id.SOLAR_PANEL:
			_raise(turn, Type.SOLAR_PANEL, 1)
		Id.HQ_LEVEL_2:
			_raise(turn, Type.HEADQUARTERS, 2)
		Id.BARRACKS_AND_SCOUTS:
			_raise(turn, Type.BARRACKS, 1)
			_recruit_scouts(turn)
		Id.EXPLORE:
			ExploreMoves.explore(turn, 1, 1, func(_p: GridPosition) -> float: return 0.0)
		Id.SOLAR_PANEL_LEVEL_2:
			_raise(turn, Type.SOLAR_PANEL, 2)
		Id.LABORATORY_AND_RESEARCH:
			_raise(turn, Type.LABORATORY, 1)
			GrowthMoves.research(turn)


## Recruits the Harpoonists the guide advises against the announced raid,
## as many as the stocks allow; when no number is enough, holds it the way
## `planner` would.
static func follow_raid_advice(turn: ScriptTurn, planner: ArmyPlanner) -> void:
	var wave := turn.player.raid_state.incoming
	var needed: Variant = RaidDefenceAdvisor.harpoonists_for(turn.player, wave)
	if needed == null:
		BattleMoves.defend_base(turn, planner)
		return
	var harpoonist: Dictionary[UnitType.Value, int] = {UnitType.Value.HARPOONIST: 1}
	if RecruitMoves.usable_mixes(turn, [harpoonist]).is_empty():
		return
	var have: int = RaidBattle.defenders_of(turn.player).get(UnitType.Value.HARPOONIST, 0)
	var wanted: int = needed
	RecruitMoves.recruit_mix(turn, harpoonist, mini(wanted - have, RecruitMoves.affordable(turn, harpoonist)))


## Upgrades `type` while it is under `level`.
static func _raise(turn: ScriptTurn, type: Type, level: int) -> void:
	if turn.player.buildings[type].level >= level:
		return
	turn.try_perform(UpgradeBuildingAction.new(type))


static func _recruit_scouts(turn: ScriptTurn) -> void:
	var scouts := turn.player.units_on_level(1)[UnitType.Value.SCOUT].count
	if scouts >= TUTORIAL_SCOUTS:
		return
	turn.try_perform(RecruitUnitAction.new(UnitType.Value.SCOUT, TUTORIAL_SCOUTS - scouts))
