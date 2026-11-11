extends TestCase
## test/presentation/widgets/army/squad_size_test.dart.


func test_stands_as_many_figures_as_the_size_tier() -> void:
	var tiers: Dictionary[int, int] = {
		0: 0, 1: 1, 2: 2, 5: 2, 6: 3, 15: 3, 16: 4, 30: 4, 31: 5, 60: 5, 61: 6, 1000: 6,
	}
	for count: int in tiers:
		assert_eq(SquadSize.of(count), tiers[count], "%d units" % count)


func test_never_stands_more_figures_than_there_are_slots() -> void:
	assert_eq(SquadSize.of(1 << 30), SquadSize.MAX)
	assert_eq(SquadSize.MAX, ParadeLayout.SLOTS.size())


func test_treats_a_negative_count_as_an_empty_squad() -> void:
	assert_eq(SquadSize.of(-3), 0)
