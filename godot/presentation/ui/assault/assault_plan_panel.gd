class_name AssaultPlanPanel
extends RefreshingPanel
## The plan of an assault on a Faille, a Cheminée or the volcanic kernel from a
## level (lib/presentation/widgets/fight/assault_plan_panel.dart): a checklist
## (an admiral sent, covered by Guardians, an army strong enough, the building
## to raise next), the chance gauge and the army the guide advises. It only
## informs: the player still picks the army.
##
## One panel follows the army being composed: [method show_plan] gives it the
## plan of the picks (see [AssaultPlans]), and it rewrites itself.

const GAP := 8
const ROW_GAP := 4

var plan: AssaultPlan
var level: int
var title_label := Label.new()
var admiral_row := AssaultCheckRow.new()
var covered_row := AssaultCheckRow.new()
var army_row := AssaultCheckRow.new()
## The building to raise next: hidden for the kernel, which opens nothing.
var next_row := AssaultCheckRow.new()
var gauge := AssaultChanceGauge.new()
var advice_label := Label.new()


## The panel of [param plan_], for an assault from [param level].
func _init(plan_: AssaultPlan, level_: int) -> void:
	plan = plan_
	level = level_
	super()
	title_label.theme_type_variation = &"LabelLarge"
	title_label.add_theme_color_override(&"font_color", AbyssColors.BIOLUM_CYAN)
	advice_label.theme_type_variation = &"BodySmall"
	advice_label.add_theme_color_override(&"font_color", AbyssColors.BIOLUM_TEAL)
	advice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", ROW_GAP)
	for part: Control in [title_label, admiral_row, covered_row, army_row, next_row, gauge, advice_label]:
		column.add_child(part)
	add_child(column)
	refresh()


## Rewrites the panel for [param new_plan].
func show_plan(new_plan: AssaultPlan) -> void:
	plan = new_plan
	refresh()


func refresh() -> void:
	title_label.text = Texts.t(&"assaultPlanTitle")
	_admiral()
	var covered := plan.admiral_covered()
	covered_row.show_point(AssaultCheckRow.State.OK if covered else AssaultCheckRow.State.WARNING,
		Texts.t(&"assaultPlanCovered"),
		Texts.t(&"assaultPlanGuardians", {"count": plan.army.get(UnitType.Value.GUARDIAN, 0)}) if covered
		else Texts.t(&"assaultPlanUncovered"))
	_army()
	next_row.visible = plan.next_step != null
	if plan.next_step != null:
		var next := plan.next_step
		next_row.show_point(AssaultCheckRow.State.OK if next.is_ready() else AssaultCheckRow.State.WARNING,
			Texts.t(&"assaultPlanNext", {"building": BuildingTexts.display_name(next.building)}),
			Texts.t(&"assaultPlanHqReady", {"current": next.current_hq}) if next.is_ready()
			else Texts.t(&"assaultPlanHqNeeded", {"required": next.required_hq, "current": next.current_hq}))
	gauge.show_chance(plan.chance())
	var advice := _advice()
	advice_label.visible = not advice.is_empty()
	advice_label.text = advice


func _admiral() -> void:
	var sent: int = plan.army.get(UnitType.Value.ABYSS_ADMIRAL, 0)
	var detail: String
	if plan.has_admiral():
		detail = Texts.t(&"assaultPlanAdmiralsIn", {"count": sent, "level": level})
	elif plan.admirals_available > 0:
		detail = Texts.t(&"assaultPlanAdmiralsLeft", {"count": plan.admirals_available, "level": level})
	else:
		var barracks := UnitCostCalculator.new().unlock_level(UnitType.Value.ABYSS_ADMIRAL)
		detail = Texts.t(&"assaultPlanAdmiralRecruit", {"level": barracks})
	admiral_row.show_point(AssaultCheckRow.State.OK if plan.has_admiral() else AssaultCheckRow.State.MISSING,
		Texts.t(&"assaultPlanAdmiral"), detail)


func _army() -> void:
	var rating := plan.chance().rating()
	var state := AssaultCheckRow.State.MISSING
	var key := &"assaultPlanArmyLow"
	if rating == AssaultRating.Value.HIGH:
		state = AssaultCheckRow.State.OK
		key = &"assaultPlanArmyHigh"
	elif rating == AssaultRating.Value.RISKY:
		state = AssaultCheckRow.State.WARNING
		key = &"assaultPlanArmyRisky"
	army_row.show_point(state, Texts.t(&"assaultPlanArmy"),
		Texts.t(key) if plan.has_admiral() else Texts.t(&"assaultPlanArmyNoAdmiral"))


## "Conseil : l'Amiral avec 4 gardiens, 10 harponneurs", or nothing when no
## army within reach is advised.
func _advice() -> String:
	var suggested: Variant = plan.suggested_army()
	if suggested == null:
		return ""
	var army: Dictionary[UnitType.Value, int] = suggested
	var escort: Array[String] = []
	for type: UnitType.Value in [UnitType.Value.GUARDIAN, UnitType.Value.HARPOONIST]:
		if army.get(type, 0) > 0:
			escort.append(UnitTexts.units(type, army[type]))
	var leader := Texts.t(&"assaultPlanAdviceLeader", {"count": army[UnitType.Value.ABYSS_ADMIRAL]})
	return Texts.t(&"assaultPlanAdvice", {"leader": leader, "escort": ", ".join(escort)})
