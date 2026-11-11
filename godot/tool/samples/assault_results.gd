class_name AssaultResults
extends RefCounted
## Real results of the assaults on the guardians of a Faille and of the
## volcano, played by the domain on the games of [PostWar] and [KernelWar]: the
## reports of the UI tests are read from them.

const Admiral := UnitType.Value.ABYSS_ADMIRAL
## An army that takes a post, and one that is wiped out.
const STRONG: Dictionary[UnitType.Value, int] = {
	UnitType.Value.ABYSS_ADMIRAL: 1, UnitType.Value.HARPOONIST: 150, UnitType.Value.GUARDIAN: 100,
}
const WEAK: Dictionary[UnitType.Value, int] = {UnitType.Value.ABYSS_ADMIRAL: 1}


## The assault of [param army] on a guarded Faille (or Cheminée, per
## [param kind]) at turn 12.
static func transition(
	army: Dictionary[UnitType.Value, int], kind := TransitionBaseType.Value.FAILLE
) -> AttackTransitionBaseResult:
	var war := PostWar.new(kind, 7, false)
	war.post.captured_by = null
	war.put(war.human(), war.level, army)
	var action := AttackTransitionBaseAction.new(war.at.x, war.at.y, war.level, army, DartRandom.new(1))
	return ActionExecutor.new().execute(action, war.game, war.human()) as AttackTransitionBaseResult


## The assault of [param army] on the volcano nobody holds.
static func kernel(army: Dictionary[UnitType.Value, int]) -> AttackVolcanicKernelResult:
	var war := KernelWar.new(3, 7, false)
	var map: GameMap = war.game.levels[KernelGarrison.VOLCANO_LEVEL]
	map.set_cell(war.at.x, war.at.y, map.cell_at(war.at.x, war.at.y).copy_with({"collected_by": null}))
	war.put(war.human(), KernelGarrison.VOLCANO_LEVEL, army)
	var action := AttackVolcanicKernelAction.new(war.at.x, war.at.y, KernelGarrison.VOLCANO_LEVEL, army, DartRandom.new(1))
	return ActionExecutor.new().execute(action, war.game, war.human()) as AttackVolcanicKernelResult
