class_name AssaultSelections
extends RefCounted
## The pages where the army of an assault is picked
## (lib/presentation/screens/game/fight/transition_army_selection_screen.dart,
## kernel_army_selection_screen.dart): the generic [ArmySelection] led by an
## Abyss Admiral, titled "Assault: <place>", over the units that serve on the
## level of the place. Whoever opens one gives the [param confirm] that sends
## the army (taking the picks, returning an [ActionResult]), and the
## [param plan] of the assault it shows before the rows ([AssaultPlans]), null
## for none. An assault on what another player holds ([method rival]) needs no
## admiral and has no plan.


## The selection for an assault on the post [param base] of [param level].
static func transition(
	human: Player, level: int, base: TransitionBase, confirm: Callable, plan: Control = null
) -> ArmySelection:
	return _page(human, level, func() -> String: return TransitionBaseNameTexts.label(base.name), confirm, plan)


## The selection for an assault on the volcano, from [param level] where it lies.
static func kernel(human: Player, level: int, confirm: Callable, plan: Control = null) -> ArmySelection:
	return _page(human, level, func() -> String: return BuildingTexts.display_name(BuildingType.Value.VOLCANIC_KERNEL),
		confirm, plan)


## The selection for an assault on the base, the post or the kernel of the
## player called [param target_name], with the units that serve on
## [param level]: no Admiral needed, and no plan.
static func rival(human: Player, level: int, target_name: String, confirm: Callable) -> ArmySelection:
	return ArmySelection.new(func() -> String: return Texts.t(&"fightAssaultOn", {"target": target_name}),
		human.units_on_level(level), ArmySelectionSummary.boost_of(human), &"fightLaunchAssault", confirm)


static func _page(human: Player, level: int, place: Callable, confirm: Callable, plan: Control) -> ArmySelection:
	return ArmySelection.new(func() -> String: return Texts.t(&"fightAssaultOn", {"target": place.call()}),
		human.units_on_level(level), ArmySelectionSummary.boost_of(human), &"fightLaunchAssault", confirm, plan, true)
