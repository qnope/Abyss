extends TestCase
## The colour of each resource, as ResourceTypeColor gives it.

const Type := ResourceType.Value


func test_each_resource_has_its_colour_of_the_palette() -> void:
	assert_eq(ResourceColors.of(Type.ALGAE), AbyssColors.ALGAE_GREEN)
	assert_eq(ResourceColors.of(Type.CORAL), AbyssColors.CORAL_PINK)
	assert_eq(ResourceColors.of(Type.ORE), AbyssColors.ORE_BLUE)
	assert_eq(ResourceColors.of(Type.ENERGY), AbyssColors.ENERGY_YELLOW)
	assert_eq(ResourceColors.of(Type.PEARL), AbyssColors.PEARL_WHITE)


func test_no_two_resources_share_a_colour() -> void:
	var seen: Array[Color] = []
	for type: ResourceType.Value in ResourceType.Value.values():
		assert_false(seen.has(ResourceColors.of(type)))
		seen.append(ResourceColors.of(type))
