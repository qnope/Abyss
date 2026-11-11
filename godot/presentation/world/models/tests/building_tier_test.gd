extends TestCase
## The bands of a building's levels (base_pad_tier.dart) and the citadel's
## rampart tiers.


func test_a_plot_has_no_tier() -> void:
	assert_eq(BuildingTier.of_level(0), 0)


func test_the_pads_rise_at_levels_1_4_and_8() -> void:
	var tiers: Array[int] = []
	for level: int in [1, 3, 4, 7, 8, 10]:
		tiers.append(BuildingTier.of_level(level))
	assert_eq(tiers, [1, 1, 2, 2, 3, 3] as Array[int])


func test_the_rampart_follows_the_citadels_five_levels() -> void:
	var tiers: Array[int] = []
	for level: int in range(0, 6):
		tiers.append(BuildingTier.rampart_of(level))
	assert_eq(tiers, [0, 1, 1, 2, 2, 3] as Array[int])
