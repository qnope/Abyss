extends TestCase
## The interface and the world each keep the colours of the six units (the
## world may not read the interface): this is the layer that sees both, so it
## checks that a unit has the same colour in its sheet and on the parade.


func test_a_unit_has_the_same_colour_in_its_sheet_and_in_the_world() -> void:
	for type: UnitType.Value in UnitType.Value.values():
		assert_eq(UnitColors.of(type), WorldPalette.unit(type), str(type))
