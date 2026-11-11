class_name AssaultPlanCase
extends UiTestCase
## What the tests of the assault plan share (assault_plan_panel_helper.dart):
## the plan of an army with a stock, and the panel that shows it.

const Admiral := UnitType.Value.ABYSS_ADMIRAL
const Guardian := UnitType.Value.GUARDIAN
const Harpoonist := UnitType.Value.HARPOONIST
const STRONG: Dictionary[UnitType.Value, int] = {Admiral: 1, Guardian: 4, Harpoonist: 10}

const OK := AssaultCheckRow.State.OK
const WARNING := AssaultCheckRow.State.WARNING
const MISSING := AssaultCheckRow.State.MISSING


## The plan of [param army] from level 1, with [param stock] standing there
## (the army itself by default) and the headquarters at [param hq].
func plan(
	army: Dictionary[UnitType.Value, int], target := AssaultTarget.Value.FAILLE,
	stock: Variant = null, hq := 4, max_harpoonists := AssaultPlan.DEFAULT_MAX_HARPOONISTS,
) -> AssaultPlan:
	var standing: Dictionary[UnitType.Value, int] = {}
	var given: Dictionary = army if stock == null else stock
	standing.assign(given)
	return AssaultPlan.of(AssaultSamples.assault_player(standing, 1, hq), 1, target, army, max_harpoonists)


## The panel of [param shown], mounted.
func panel_of(shown: AssaultPlan) -> AssaultPlanPanel:
	return mount(AssaultPlanPanel.new(shown, 1)) as AssaultPlanPanel
