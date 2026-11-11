extends TestCase
## The colour of each building, as BuildingTypeColor gives it, apart where the
## Flutter palette made two buildings look alike.

const Type := BuildingType.Value


func test_keeps_the_flutter_colour_of_the_buildings_that_were_apart() -> void:
	assert_eq(BuildingColors.of(Type.HEADQUARTERS), AbyssColors.BIOLUM_PURPLE)
	assert_eq(BuildingColors.of(Type.ALGAE_FARM), AbyssColors.ALGAE_GREEN)
	assert_eq(BuildingColors.of(Type.CORAL_MINE), AbyssColors.CORAL_PINK)
	assert_eq(BuildingColors.of(Type.ORE_EXTRACTOR), AbyssColors.ORE_BLUE)
	assert_eq(BuildingColors.of(Type.SOLAR_PANEL), AbyssColors.ENERGY_YELLOW)
	assert_eq(BuildingColors.of(Type.LABORATORY), AbyssColors.BIOLUM_TEAL)
	assert_eq(BuildingColors.of(Type.PRESSURE_CAPSULE), AbyssColors.BIOLUM_CYAN)


func test_no_two_buildings_share_a_colour() -> void:
	var seen: Array[Color] = []
	for type: BuildingType.Value in Type.values():
		assert_false(seen.has(BuildingColors.of(type)), str(type))
		seen.append(BuildingColors.of(type))
	assert_eq(seen.size(), 11)
