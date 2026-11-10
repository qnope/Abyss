extends VectorTestCase
## test/domain/resource/production_formulas_test.dart: what each production
## building makes, and the buildingProduction section of resources.json.

const FARM := BuildingType.Value.ALGAE_FARM
const MINE := BuildingType.Value.CORAL_MINE
const EXTRACTOR := BuildingType.Value.ORE_EXTRACTOR
const PANEL := BuildingType.Value.SOLAR_PANEL


func _amounts(type: BuildingType.Value) -> Array[int]:
	var formula := ProductionFormulas.production_formulas()[type]
	var amounts: Array[int] = []
	for level: int in range(1, 6):
		amounts.append(formula.compute(level))
	return amounts


func test_production_formulas_algae_farm_returns_expected_values_for_levels_1_5() -> void:
	assert_eq(_amounts(FARM), [50, 140, 230, 320, 410])


func test_production_formulas_coral_mine_returns_expected_values_for_levels_1_5() -> void:
	assert_eq(_amounts(MINE), [40, 100, 160, 220, 280])


func test_production_formulas_ore_extractor_returns_expected_values_for_levels_1_5() -> void:
	assert_eq(_amounts(EXTRACTOR), [30, 90, 150, 210, 270])


func test_production_formulas_solar_panel_returns_expected_values_for_levels_1_5() -> void:
	assert_eq(_amounts(PANEL), [19, 59, 99, 138, 178])


func test_production_formulas_headquarters_is_not_in_the_map() -> void:
	assert_false(ProductionFormulas.production_formulas().has(BuildingType.Value.HEADQUARTERS))


func test_production_formulas_each_formula_returns_the_correct_resource_type() -> void:
	var formulas := ProductionFormulas.production_formulas()
	assert_eq(formulas[FARM].resource_type, ResourceType.Value.ALGAE)
	assert_eq(formulas[MINE].resource_type, ResourceType.Value.CORAL)
	assert_eq(formulas[EXTRACTOR].resource_type, ResourceType.Value.ORE)
	assert_eq(formulas[PANEL].resource_type, ResourceType.Value.ENERGY)


## Not in the Dart file: the map iterates in the order Dart wrote it.
func test_lists_the_buildings_in_the_order_of_dart() -> void:
	assert_eq(ProductionFormulas.production_formulas().keys(), [FARM, MINE, EXTRACTOR, PANEL])


func test_building_production_vectors() -> void:
	var cases := VectorFile.new("resources").cases("buildingProduction")
	assert_eq(cases.size(), 48)
	var formulas := ProductionFormulas.production_formulas()
	for case: Dictionary in cases:
		var type := VectorInputs.value(BuildingType.Value, case["type"]) as BuildingType.Value
		var level: int = case["level"]
		var formula := formulas[type]
		var out := {
			"amount": formula.compute(level),
			"resource": DartEnum.name_of(ResourceType.Value, formula.resource_type),
		}
		assert_same(out, case["out"], str(case))
