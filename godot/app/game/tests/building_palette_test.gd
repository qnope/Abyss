extends TestCase
## The interface and the world each keep the colours of the eleven buildings
## (the world may not read the interface): this is the layer that sees both,
## so it checks that a building has the same colour in its sheet and on the
## base.


func test_a_building_has_the_same_colour_in_its_sheet_and_in_the_world() -> void:
	for type: BuildingType.Value in BuildingType.Value.values():
		assert_eq(BuildingColors.of(type), WorldPalette.of(type), str(type))
