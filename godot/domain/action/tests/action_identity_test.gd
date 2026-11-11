extends TestCase
## test/domain/action/action_identity_test.dart: each player action with the
## kind it reports and the line a script log writes for it.

const UNITS: Dictionary[UnitType.Value, int] = {UnitType.Value.HARPOONIST: 3}
const T := ActionType.Value


func _actions() -> Array:
	return [
		[ResearchTechAction.new(TechBranch.Value.MILITARY), T.RESEARCH_TECH, "Rechercher tech TechBranch.military"],
		[UnlockBranchAction.new(TechBranch.Value.EXPLORER), T.UNLOCK_BRANCH, "Debloquer branche TechBranch.explorer"],
		[RecruitUnitAction.new(UnitType.Value.SCOUT, 2), T.RECRUIT_UNIT, "Recruter 2 UnitType.scout"],
		[ExploreAction.new(4, 5), T.EXPLORE, "Explorer (4, 5)"],
		[CollectTreasureAction.new(1, 2), T.COLLECT_TREASURE, "Collecter (1, 2)"],
		[FightMonsterAction.new(3, 6, 1, UNITS), T.FIGHT_MONSTER, "Combat (3, 6)"],
		[AttackTransitionBaseAction.new(7, 8, 1, UNITS), T.ATTACK_TRANSITION_BASE, "Assaut base (7, 8)"],
		[AttackVolcanicKernelAction.new(0, 0, 3, UNITS), T.ATTACK_VOLCANIC_KERNEL, "Assaut Noyau Volcanique"],
		[AttackBaseAction.new("rival", UNITS), T.ATTACK_BASE, "Attaque base rival"],
		[AttackPostAction.new(4, 5, 2, UNITS), T.ATTACK_POST, "Attaque poste (4, 5)"],
		[DescendAction.new(2, 2, 1, UNITS), T.DESCEND, "Descente niveau 1"],
		[SendReinforcementsAction.new(2, 2, 1, UNITS), T.SEND_REINFORCEMENTS, "Envoyer des renforts"],
		[GarrisonKernelAction.new(UNITS), T.GARRISON_KERNEL, "Mettre en garnison"],
		[GarrisonKernelAction.new(UNITS, true), T.GARRISON_KERNEL, "Retirer de la garnison"],
	]


func test_each_action_is_logged_as_its_line() -> void:
	for row: Array in _actions():
		var action: Action = row[0]
		var type: ActionType.Value = row[1]
		var line: String = row[2]
		var name := DartEnum.name_of(ActionType.Value, type)
		assert_eq(action.type(), type, name)
		assert_eq(action.description(), line, name)
