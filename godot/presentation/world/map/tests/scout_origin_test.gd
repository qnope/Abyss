extends TestCase
## test/presentation/widgets/map/scout_origin_test.dart.

const Holder := PostHolder.Value


func _cells(cells: Array[Vector2i]) -> Dictionary[Vector2i, bool]:
	var set_: Dictionary[Vector2i, bool] = {}
	for cell in cells:
		set_[cell] = true
	return set_


func test_a_scout_of_the_first_level_sets_off_from_the_base() -> void:
	var origin := ScoutOrigin.of(Vector2i(3, 4), Vector2i(10, 10), {}, _cells([Vector2i(3, 3)]))
	assert_eq(origin, Vector2i(10, 10))


func test_deeper_it_sets_off_from_the_nearest_post_the_player_holds() -> void:
	var holders: Dictionary[Vector2i, Holder] = {
		Vector2i(15, 15): Holder.HUMAN, Vector2i(3, 3): Holder.FACTION,
		Vector2i(1, 6): Holder.GUARDIANS, Vector2i(8, 8): Holder.HUMAN,
	}
	assert_eq(ScoutOrigin.of(Vector2i(2, 2), null, holders, _cells([Vector2i(2, 1)])), Vector2i(8, 8))


func test_without_a_post_it_sets_off_from_the_nearest_revealed_cell() -> void:
	var holders: Dictionary[Vector2i, Holder] = {Vector2i(4, 4): Holder.FACTION}
	var seen := _cells([Vector2i(9, 9), Vector2i(5, 5), Vector2i(6, 4), Vector2i(4, 6), Vector2i(0, 0)])
	# Two cells are as near: the upper one wins, whatever the order of the set.
	assert_eq(ScoutOrigin.of(Vector2i(5, 5), null, holders, seen), Vector2i(6, 4))
	var reversed := _cells([Vector2i(0, 0), Vector2i(4, 6), Vector2i(6, 4), Vector2i(5, 5), Vector2i(9, 9)])
	assert_eq(ScoutOrigin.of(Vector2i(5, 5), null, holders, reversed), Vector2i(6, 4))
	# On the same row, the left one.
	assert_eq(ScoutOrigin.of(Vector2i(5, 5), null, {}, _cells([Vector2i(7, 5), Vector2i(3, 5)])), Vector2i(3, 5))


func test_with_nothing_revealed_it_appears_on_the_target_itself() -> void:
	assert_eq(ScoutOrigin.of(Vector2i(5, 5), null, {}, {}), Vector2i(5, 5))
