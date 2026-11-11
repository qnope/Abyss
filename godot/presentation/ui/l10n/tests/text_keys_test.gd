extends TestCase


func test_builds_the_key_from_the_dart_name_of_the_value() -> void:
	assert_eq(TextKeys.of("building", BuildingType.Value, BuildingType.Value.ALGAE_FARM, "Name"), &"buildingAlgaeFarmName")
	assert_eq(TextKeys.of("unit", UnitType.Value, UnitType.Value.ABYSS_ADMIRAL, "RoleEffect"), &"unitAbyssAdmiralRoleEffect")


func test_a_name_of_one_word_and_no_suffix() -> void:
	assert_eq(TextKeys.of("resource", ResourceType.Value, ResourceType.Value.ORE), &"resourceOre")


func test_a_part_of_the_name_alone_is_capitalised_too() -> void:
	assert_eq(TextKeys.capitalised("domeBreaker"), "DomeBreaker")
	assert_eq(TextKeys.capitalised("a"), "A")
	assert_eq(TextKeys.capitalised(""), "")
