extends TestCase
## test/domain/building/building_deactivator_test.dart: the buildings shut
## down when the energy runs short, the least needed first.

const HQ := BuildingType.Value.HEADQUARTERS
const FARM := BuildingType.Value.ALGAE_FARM
const MINE := BuildingType.Value.CORAL_MINE
const EXTRACTOR := BuildingType.Value.ORE_EXTRACTOR
const PANEL := BuildingType.Value.SOLAR_PANEL
const LABORATORY := BuildingType.Value.LABORATORY
const BARRACKS := BuildingType.Value.BARRACKS
const CITADEL := BuildingType.Value.CORAL_CITADEL
const KERNEL := BuildingType.Value.VOLCANIC_KERNEL


func _deactivate(
	levels: Dictionary[BuildingType.Value, int], production: int, stock: int
) -> Array[BuildingType.Value]:
	return BuildingDeactivator.deactivate(DomainSamples.buildings(levels), production, stock)


func test_deactivate_no_deficit_returns_empty_list() -> void:
	# consumption: HQ lvl2=6, algae lvl3=6, solar lvl5=5 → 17
	assert_eq(_deactivate({HQ: 2, FARM: 3, PANEL: 5}, 50, 0), [])


func test_deactivate_exact_balance_returns_empty_list() -> void:
	# HQ lvl1=3, algae lvl1=2 → consumption=5
	assert_eq(_deactivate({HQ: 1, FARM: 1}, 3, 2), [])


func test_deactivate_disables_ore_extractor_first() -> void:
	# HQ lvl1=3, oreExtractor lvl1=3 → consumption=6, available=4, deficit=2
	assert_eq(_deactivate({HQ: 1, EXTRACTOR: 1}, 0, 4), [EXTRACTOR])


func test_deactivate_disables_multiple_buildings_in_priority_order() -> void:
	# HQ lvl1=3, oreExtractor lvl1=3, coralMine lvl1=2 → 8, available=2
	assert_eq(_deactivate({HQ: 1, EXTRACTOR: 1, MINE: 1}, 2, 0), [EXTRACTOR, MINE])


func test_deactivate_never_disables_headquarters() -> void:
	# HQ lvl5=15, huge deficit, available=0
	assert_false(_deactivate({HQ: 5}, 0, 0).has(HQ))


func test_deactivate_skips_level_0_buildings() -> void:
	# HQ lvl1=3, oreExtractor lvl0=0, coralMine lvl1=2 → 5, available=2
	assert_eq(_deactivate({HQ: 1, EXTRACTOR: 0, MINE: 1}, 2, 0), [MINE])


func test_deactivate_uses_stock_to_cover_deficit() -> void:
	# HQ lvl2=6, algae lvl2=4, coralMine lvl2=4 → 14, available=30
	assert_eq(_deactivate({HQ: 2, FARM: 2, MINE: 2}, 10, 20), [])


func test_deactivate_stock_not_enough_triggers_deactivation() -> void:
	# HQ lvl2=6, algae lvl2=4, oreExtractor lvl2=6 → 16, available=15, deficit=1
	assert_eq(_deactivate({HQ: 2, FARM: 2, EXTRACTOR: 2}, 10, 5), [EXTRACTOR])


func test_deactivate_all_non_hq_buildings_deactivated_in_extreme_deficit() -> void:
	var levels: Dictionary[BuildingType.Value, int] = {
		HQ: 1, PANEL: 1, BARRACKS: 1, LABORATORY: 1, FARM: 1, MINE: 1, EXTRACTOR: 1,
	}
	var result := _deactivate(levels, 0, 0)
	assert_eq(result.size(), 6)
	assert_false(result.has(HQ))


func test_deactivate_solar_panel_disabled_last_before_hq() -> void:
	var levels: Dictionary[BuildingType.Value, int] = {
		HQ: 1, PANEL: 1, BARRACKS: 1, LABORATORY: 1, FARM: 1, MINE: 1, EXTRACTOR: 1,
	}
	assert_eq(_deactivate(levels, 0, 0).back(), PANEL)


func test_deactivate_coral_citadel_is_deactivated_last_when_all_buildings_level_1() -> void:
	# Consumption: HQ=3, citadel=1, solar=1, barracks=3, lab=4, algae=2,
	# coralMine=2, ore=3 => total 19: every non-HQ must go down.
	var levels: Dictionary[BuildingType.Value, int] = {
		HQ: 1, CITADEL: 1, PANEL: 1, BARRACKS: 1, LABORATORY: 1, FARM: 1, MINE: 1, EXTRACTOR: 1,
	}
	var result := _deactivate(levels, 0, 0)
	assert_eq(result.size(), 7)
	assert_false(result.has(HQ))
	assert_eq(result.back(), CITADEL)


func test_deactivate_coral_citadel_is_spared_when_ore_extractor_alone_closes_deficit() -> void:
	# HQ lvl1=3, citadel lvl1=1, oreExtractor lvl1=3 => 7, available=4.
	assert_eq(_deactivate({HQ: 1, CITADEL: 1, EXTRACTOR: 1}, 4, 0), [EXTRACTOR])


func test_deactivate_volcanic_kernel_is_in_the_priority_list() -> void:
	assert_has(_deactivate({HQ: 1, KERNEL: 1, CITADEL: 1, EXTRACTOR: 1}, 0, 0), KERNEL)


func test_deactivate_volcanic_kernel_is_not_among_first_buildings_disabled() -> void:
	# HQ lvl1=3, volcanic lvl1=0, citadel lvl1=1, ore lvl1=3, available=5.
	assert_eq(_deactivate({HQ: 1, KERNEL: 1, CITADEL: 1, EXTRACTOR: 1}, 5, 0), [EXTRACTOR])


func test_deactivate_skips_level_0_coral_citadel() -> void:
	# HQ lvl1=3, citadel lvl0=0, oreExtractor lvl1=3 => total 6, available=0.
	assert_eq(_deactivate({HQ: 1, CITADEL: 0, EXTRACTOR: 1}, 0, 0), [EXTRACTOR])
