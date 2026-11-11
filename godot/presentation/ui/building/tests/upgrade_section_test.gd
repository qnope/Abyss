extends BuildingTestCase
## What it takes to raise a building (upgrade_section_test.dart): the costs,
## the noise, the prerequisites, the worksite, each red until met.

const Type := BuildingType.Value

var _pressed := 0


func _section(type: BuildingType.Value) -> UpgradeSection:
	var section := UpgradeSection.new(view_of(type))
	section.upgrade_pressed.connect(func() -> void: _pressed += 1)
	mount(section)
	return section


func after_each() -> void:
	_pressed = 0


func test_tells_the_level_it_goes_to_and_what_it_costs() -> void:
	set_levels({Type.HEADQUARTERS: 1})
	var section := _section(Type.HEADQUARTERS)
	assert_not_null(find_text("Niveau 1 → 2", section))
	var cost := view_of(Type.HEADQUARTERS).calculator.upgrade_cost(Type.HEADQUARTERS, 1)
	for resource: ResourceType.Value in cost:
		var have := human.resources[resource].amount
		assert_not_null(find_text("%d/%d" % [have, cost[resource]], section), str(resource))
		assert_not_null(find_text(ResourceTexts.display_name(resource), section))
	assert_no_raw_keys()


func test_tells_the_noise_the_upgrade_makes() -> void:
	set_levels({Type.HEADQUARTERS: 1})
	var section := _section(Type.HEADQUARTERS)
	assert_not_null(find_text("Bruit", section))
	assert_not_null(find_text("+2", section))


func test_the_costs_are_red_until_the_stock_holds_them() -> void:
	set_levels({Type.HEADQUARTERS: 1})
	human.resources[ResourceType.Value.CORAL].amount = 0
	var section := _section(Type.HEADQUARTERS)
	var coral := requirement(section, "Corail")
	assert_false(coral.met)
	assert_eq(coral.label.get_theme_color(&"font_color"), AbyssColors.ERROR)
	assert_eq(coral.amount_label.get_theme_color(&"font_color"), AbyssColors.ERROR)


func test_the_button_builds_a_building_that_is_not_there_and_upgrades_the_others() -> void:
	set_levels({Type.HEADQUARTERS: 0})
	assert_eq(_section(Type.HEADQUARTERS).button.text, "Construire")
	set_levels({Type.HEADQUARTERS: 2})
	assert_eq(_section(Type.HEADQUARTERS).button.text, "Améliorer")


func test_a_building_that_can_rise_has_a_lit_button_that_tells_the_press() -> void:
	set_levels({Type.HEADQUARTERS: 1})
	fill_stores()
	var section := _section(Type.HEADQUARTERS)
	assert_false(section.button.disabled)
	press(section.button)
	assert_eq(_pressed, 1)


func test_without_the_stock_the_button_is_dark() -> void:
	set_levels({Type.HEADQUARTERS: 1})
	human.resources[ResourceType.Value.CORAL].amount = 0
	assert_true(_section(Type.HEADQUARTERS).button.disabled)


func test_lists_the_buildings_it_asks_for_red_until_they_stand() -> void:
	set_levels({Type.HEADQUARTERS: 2, Type.LABORATORY: 0})
	fill_stores()
	var section := _section(Type.BARRACKS)
	assert_not_null(find_text("Quartier Général", section))
	assert_not_null(find_text("Niv. 2", section), "met: the headquarters is at 2")
	assert_false(section.button.disabled)
	set_levels({Type.HEADQUARTERS: 1})
	section = _section(Type.BARRACKS)
	assert_true(section.button.disabled)
	assert_false(requirement(section, "Quartier Général").met)


func test_a_building_at_its_top_level_says_so() -> void:
	set_levels({Type.HEADQUARTERS: 10, Type.DESCENT_MODULE: 1})
	var section := _section(Type.DESCENT_MODULE)
	assert_not_null(find_text("Niveau maximum atteint", section))
	assert_null(section.button)


func test_asks_for_a_free_worksite() -> void:
	set_levels({Type.HEADQUARTERS: 1})
	fill_stores()
	human.worksite.upgrades = 1
	var section := _section(Type.HEADQUARTERS)
	assert_not_null(find_text("Chantiers occupés ce tour", section))
	assert_true(section.button.disabled)


func test_asks_for_a_base_to_be_captured_and_for_the_kernel() -> void:
	var readiness := UpgradeReadiness.new(UpgradeCheck.new(false, false, {}, {},
		TransitionBaseType.Value.FAILLE, true), true)
	var view := view_of(Type.DESCENT_MODULE)
	view.readiness = readiness
	var section := UpgradeSection.new(view)
	mount(section)
	assert_not_null(find_text("Faille Abyssale capturée requise", section))
	assert_not_null(find_text("Noyau Volcanique capturé requis", section))
	assert_true(section.button.disabled)


func test_the_research_discount_lowers_the_cost() -> void:
	set_levels({Type.HEADQUARTERS: 1})
	var view := view_of(Type.HEADQUARTERS)
	view.calculator = BuildingCostCalculator.new(50)
	var section := UpgradeSection.new(view)
	mount(section)
	var full := BuildingCostCalculator.new().upgrade_cost(Type.HEADQUARTERS, 1)
	var coral := full[ResourceType.Value.CORAL] if full.has(ResourceType.Value.CORAL) else 0
	var half := DartMath.trunc_div(coral * 50, 100)
	assert_not_null(find_text("%d/%d" % [human.resources[ResourceType.Value.CORAL].amount, half], section))

