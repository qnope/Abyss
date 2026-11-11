class_name ActionCodec
extends RefCounted
## lib/domain/script/action_codec.dart: reads one action of a JSON scenario,
## such as `{"do": "recruit", "unit": "guardian", "count": 5}`.
##
## Every player action of the game has a verb; enum values use their Dart
## names (`algaeFarm`, `military`, `harpoonist`...). An action that rolls
## dice may carry a `seed`, written by an exported replay, to roll the same
## dice as the game it comes from.
##
## lib/domain/script/action_spec.dart is a typedef: an `ActionSpec` is a
## `Callable` that takes the game's `DartRandom` and returns the `Action`,
## built when a script is about to play it.


## The spec of the action. Where Dart throws a FormatException right away,
## rather than in the middle of a game, this logs the error (`ActionFields`)
## and returns an invalid `Callable()`.
static func decode(json: Dictionary) -> Callable:
	var fields := ActionFields.new(json)
	var spec := _spec_of(fields)
	if spec.is_valid():
		spec.call(DartRandom.new(0, false))
	return Callable() if fields.failed else spec


static func _spec_of(f: ActionFields) -> Callable:
	match f.text("do"):
		"upgrade":
			return func(_r: DartRandom) -> Action:
				return UpgradeBuildingAction.new(f.enum_of(BuildingType.Value, "building") as BuildingType.Value)
		"unlock":
			return func(_r: DartRandom) -> Action:
				return UnlockBranchAction.new(f.enum_of(TechBranch.Value, "branch") as TechBranch.Value)
		"research":
			return func(_r: DartRandom) -> Action:
				var branch := f.enum_of(TechBranch.Value, "branch") as TechBranch.Value
				var option := TechOption.Value.A
				if f.json.has("option"):
					option = f.enum_of(TechOption.Value, "option") as TechOption.Value
				return ResearchTechAction.new(branch, option)
		"recruit":
			return func(_r: DartRandom) -> Action:
				return RecruitUnitAction.new(f.enum_of(UnitType.Value, "unit") as UnitType.Value, f.integer("count"))
		"explore":
			return func(_r: DartRandom) -> Action:
				return ExploreAction.new(f.integer("x"), f.integer("y"), f.level())
		"collect":
			return func(r: DartRandom) -> Action:
				return CollectTreasureAction.new(f.integer("x"), f.integer("y"), f.level(), f.rng(r))
		"fight":
			return func(r: DartRandom) -> Action:
				return FightMonsterAction.new(f.integer("x"), f.integer("y"), f.level(), f.units(), f.rng(r))
		"attackBase":
			return func(r: DartRandom) -> Action:
				return AttackTransitionBaseAction.new(f.integer("x"), f.integer("y"), f.level(), f.units(), f.rng(r))
		"attackPlayer":
			return func(r: DartRandom) -> Action:
				return AttackBaseAction.new(f.text("target"), f.units(), f.rng(r))
		"attackPost":
			return func(r: DartRandom) -> Action:
				return AttackPostAction.new(f.integer("x"), f.integer("y"), f.level(), f.units(), f.rng(r))
		"attackHeldKernel":
			return func(r: DartRandom) -> Action:
				return AttackHeldKernelAction.new(f.integer("x"), f.integer("y"), f.units(), f.rng(r))
		"spy":
			return func(_r: DartRandom) -> Action:
				return SpyBaseAction.new(f.text("target"))
		"announceAttack":
			return func(r: DartRandom) -> Action:
				return AnnounceAttackAction.new(f.units(), f.rng(r))
		"attackKernel":
			return func(r: DartRandom) -> Action:
				return AttackVolcanicKernelAction.new(f.integer("x"), f.integer("y"), f.level(), f.units(), f.rng(r))
		"descend":
			return func(r: DartRandom) -> Action:
				return DescendAction.new(f.integer("x"), f.integer("y"), f.level(), f.units(), f.rng(r))
		"reinforce":
			return func(_r: DartRandom) -> Action:
				return SendReinforcementsAction.new(f.integer("x"), f.integer("y"), f.level(), f.units())
		"garrison":
			return func(_r: DartRandom) -> Action:
				return GarrisonKernelAction.new(f.units())
		"withdraw":
			return func(_r: DartRandom) -> Action:
				return GarrisonKernelAction.new(f.units(), true)
		"event":
			return func(_r: DartRandom) -> Action:
				return ChooseEventAction.new(f.boolean("accept"))
	if not f.failed:
		push_error("Action inconnue : %s" % f.text("do"))
		f.failed = true
	return Callable()
