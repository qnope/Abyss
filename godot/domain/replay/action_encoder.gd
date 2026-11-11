class_name ActionEncoder
extends RefCounted
## lib/domain/replay/action_encoder.dart: writes a player action in the JSON
## scenario format `ActionCodec` reads, such as `{"do": "recruit", "unit":
## "guardian", "count": 5}`.
##
## An action that rolls dice also carries the `seed` of its generator when
## it is a `SeededRandom` (`is_seeded`), so that a replay rolls the same
## dice. Dart's `switch` on the class of the action is a chain of `is`, not
## a `match` on its type, which a test's own action may share; its last
## case, `_ => null`, is the return after it.

## The move as a Dictionary, or null for an action that is not a player move
## (ending the turn). An attack on `human_id` (a `String?`) names its target
## `human`, whose id changes from one game to the next.
static func encode(action: Action, human_id: Variant = null) -> Variant:
	if action is UpgradeBuildingAction:
		var upgrade: UpgradeBuildingAction = action
		return {"do": "upgrade", "building": DartEnum.name_of(BuildingType.Value, upgrade.building_type)}
	if action is UnlockBranchAction:
		var unlock: UnlockBranchAction = action
		return {"do": "unlock", "branch": DartEnum.name_of(TechBranch.Value, unlock.branch)}
	if action is ResearchTechAction:
		var research: ResearchTechAction = action
		var move := {"do": "research", "branch": DartEnum.name_of(TechBranch.Value, research.branch)}
		if research.option != TechOption.Value.A:
			move["option"] = DartEnum.name_of(TechOption.Value, research.option)
		return move
	if action is RecruitUnitAction:
		var recruit: RecruitUnitAction = action
		return {"do": "recruit", "unit": DartEnum.name_of(UnitType.Value, recruit.unit_type), "count": recruit.quantity}
	if action is ExploreAction:
		var explore: ExploreAction = action
		return _at("explore", explore.target_x, explore.target_y, explore.level)
	if action is CollectTreasureAction:
		var collect: CollectTreasureAction = action
		return _at("collect", collect.target_x, collect.target_y, collect.level, null, collect.random)
	if action is FightMonsterAction:
		var fight: FightMonsterAction = action
		return _at("fight", fight.target_x, fight.target_y, fight.level, fight.selected_units, fight.random)
	if action is AttackTransitionBaseAction:
		var siege: AttackTransitionBaseAction = action
		return _at("attackBase", siege.target_x, siege.target_y, siege.level, siege.selected_units, siege.random)
	if action is AttackBaseAction:
		var assault: AttackBaseAction = action
		return _seeded({
			"do": "attackPlayer",
			"target": _target(assault.target_player_id, human_id, AttackBaseAction.HUMAN),
			"units": _units_of(assault.selected_units),
		}, assault.random)
	if action is AttackPostAction:
		var post: AttackPostAction = action
		return _at("attackPost", post.target_x, post.target_y, post.level, post.selected_units, post.random)
	if action is AttackHeldKernelAction:
		var held: AttackHeldKernelAction = action
		return _at(
			"attackHeldKernel", held.target_x, held.target_y, KernelGarrison.VOLCANO_LEVEL,
			held.selected_units, held.random
		)
	if action is SpyBaseAction:
		var spy: SpyBaseAction = action
		return {"do": "spy", "target": _target(spy.target_player_id, human_id, SpyBaseAction.HUMAN)}
	if action is AnnounceAttackAction:
		var announce: AnnounceAttackAction = action
		return _seeded({"do": "announceAttack", "units": _units_of(announce.selected_units)}, announce.random)
	if action is AttackVolcanicKernelAction:
		var kernel: AttackVolcanicKernelAction = action
		return _at("attackKernel", kernel.target_x, kernel.target_y, kernel.level, kernel.selected_units, kernel.random)
	if action is DescendAction:
		var descend: DescendAction = action
		return _at(
			"descend", descend.transition_x, descend.transition_y, descend.from_level,
			descend.selected_units, descend.random
		)
	if action is SendReinforcementsAction:
		var reinforce: SendReinforcementsAction = action
		return _at(
			"reinforce", reinforce.transition_x, reinforce.transition_y, reinforce.from_level,
			reinforce.selected_units
		)
	if action is GarrisonKernelAction:
		var garrison: GarrisonKernelAction = action
		return {"do": "withdraw" if garrison.withdraw else "garrison", "units": _units_of(garrison.selected_units)}
	if action is ChooseEventAction:
		var choice: ChooseEventAction = action
		return {"do": "event", "accept": choice.accept}
	return null


## Whether replaying `action` rolls the same dice as playing it did.
static func is_exact(action: Action) -> bool:
	var rolls := (
		action is CollectTreasureAction or action is FightMonsterAction
		or action is AttackTransitionBaseAction or action is AttackBaseAction
		or action is AttackPostAction or action is AttackHeldKernelAction
		or action is AnnounceAttackAction or action is AttackVolcanicKernelAction
		or action is DescendAction
	)
	if not rolls:
		return true
	var random: DartRandom = action.get("random")
	return random != null and random.is_seeded


static func _units_of(units: Dictionary[UnitType.Value, int]) -> Dictionary:
	var named := {}
	for type: UnitType.Value in units:
		if units[type] > 0:
			named[DartEnum.name_of(UnitType.Value, type)] = units[type]
	return named


static func _target(target_id: String, human_id: Variant, human: String) -> String:
	return human if human_id != null and target_id == human_id else target_id


static func _seeded(move: Dictionary, random: DartRandom) -> Dictionary:
	if random != null and random.is_seeded:
		move["seed"] = random.initial_seed
	return move


static func _at(
	verb: String, x: int, y: int, level: int,
	units: Variant = null, random: DartRandom = null,
) -> Dictionary:
	var move := {"do": verb, "x": x, "y": y}
	if level != 1:
		move["level"] = level
	if units != null:
		var selected: Dictionary[UnitType.Value, int] = units
		move["units"] = _units_of(selected)
	return _seeded(move, random)
