extends TestCase
## test/domain/fight/fenwick_tree_test.dart: counts per position, with their
## prefix sums and the position of the n-th unit of count.

const GAPPED: Array[int] = [0, 1, 0, 1, 1, 0, 0, 1]
const ODD: Array[int] = [1, 0, 2, 1, 0, 0, 1, 1, 0, 3, 0, 1, 1]


## A tree of `size` positions holding a 1 at each of `ones`.
func _with_ones(size: int, ones: Array[int]) -> FenwickTree:
	var tree := FenwickTree.new(size)
	for position: int in ones:
		tree.add(position, 1)
	return tree


## A tree built with one `add` per non-zero entry of `counts`.
func _added(counts: Array[int]) -> FenwickTree:
	var tree := FenwickTree.new(counts.size())
	for position: int in counts.size():
		if counts[position] != 0:
			tree.add(position, counts[position])
	return tree


func _built(counts: Array[int]) -> FenwickTree:
	return FenwickTree.from_counts(PackedInt64Array(counts))


## Checks `a` and `b` agree on every read.
func _expect_same(a: FenwickTree, b: FenwickTree) -> void:
	assert_eq(a.size, b.size)
	assert_eq(a.total, b.total)
	for end: int in a.size + 1:
		assert_eq(a.prefix(end), b.prefix(end), "prefix(%d)" % end)
	for position: int in a.size:
		assert_eq(a.at(position), b.at(position), "at(%d)" % position)
	for n: int in a.total:
		assert_eq(a.position_of_nth(n), b.position_of_nth(n), "nth(%d)" % n)


func test_fenwick_tree_starts_empty() -> void:
	var tree := FenwickTree.new(8)
	assert_eq(tree.total, 0)
	assert_eq(tree.prefix(8), 0)
	assert_eq(tree.at(3), 0)


func test_fenwick_tree_add_updates_total_prefix_sums_and_point_counts() -> void:
	var tree := _with_ones(8, [1, 3, 4, 7])

	assert_eq(tree.total, 4)
	assert_eq(tree.prefix(0), 0)
	assert_eq(tree.prefix(1), 0)
	assert_eq(tree.prefix(2), 1)
	assert_eq(tree.prefix(4), 2)
	assert_eq(tree.prefix(5), 3)
	assert_eq(tree.prefix(8), 4)
	assert_eq(tree.at(3), 1)
	assert_eq(tree.at(2), 0)


func test_fenwick_tree_position_of_nth_walks_a_pattern_with_gaps_in_order() -> void:
	var tree := _with_ones(8, [1, 3, 4, 7])

	assert_eq(tree.position_of_nth(0), 1)
	assert_eq(tree.position_of_nth(1), 3)
	assert_eq(tree.position_of_nth(2), 4)
	assert_eq(tree.position_of_nth(3), 7)


func test_fenwick_tree_position_of_nth_skips_removed_positions() -> void:
	var tree := _with_ones(8, [1, 3, 4, 7])

	tree.add(3, -1)

	assert_eq(tree.total, 3)
	assert_eq(tree.prefix(4), 1)
	assert_eq(tree.at(3), 0)
	assert_eq(tree.position_of_nth(0), 1)
	assert_eq(tree.position_of_nth(1), 4)
	assert_eq(tree.position_of_nth(2), 7)


func test_fenwick_tree_works_on_a_size_that_is_not_a_power_of_two() -> void:
	var all: Array[int] = []
	all.assign(range(13))
	var tree := _with_ones(13, all)

	for position: int in all:
		assert_eq(tree.position_of_nth(position), position)
		assert_eq(tree.prefix(position), position)
	assert_eq(tree.position_of_nth(12), 12)


func test_fenwick_tree_counts_above_one_are_summed() -> void:
	var tree := FenwickTree.new(4)
	tree.add(2, 3)
	tree.add(0, 2)

	assert_eq(tree.total, 5)
	assert_eq(tree.at(2), 3)
	assert_eq(tree.prefix(3), 5)
	assert_eq(tree.position_of_nth(1), 0)
	assert_eq(tree.position_of_nth(2), 2)
	assert_eq(tree.position_of_nth(4), 2)


func test_from_counts_equals_a_tree_built_with_add_on_a_gapped_pattern() -> void:
	_expect_same(_built(GAPPED), _added(GAPPED))


func test_from_counts_equals_a_tree_built_with_add_on_a_size_that_is_not_a_power_of_two() -> void:
	_expect_same(_built(ODD), _added(ODD))


func test_from_counts_keeps_accepting_updates() -> void:
	var built := _built(ODD)
	var added := _added(ODD)
	built.add(9, -2)
	added.add(9, -2)
	built.add(4, 1)
	added.add(4, 1)

	_expect_same(built, added)


func test_from_counts_does_not_share_the_counts_it_was_given() -> void:
	var counts := PackedInt64Array([1, 1])
	var tree := FenwickTree.from_counts(counts)
	counts[0] = 5

	assert_eq(tree.at(0), 1)
	assert_eq(tree.total, 2)


func test_from_counts_handles_no_positions() -> void:
	var tree := FenwickTree.from_counts(PackedInt64Array())
	assert_eq(tree.size, 0)
	assert_eq(tree.total, 0)


## Not in the Dart file: a count beyond 32 bits stays whole, as a Dart int.
func test_holds_counts_beyond_32_bits() -> void:
	var tree := FenwickTree.from_counts(PackedInt64Array([5000000000, 1]))
	tree.add(1, 5000000000)
	assert_eq([tree.at(0), tree.prefix(2), tree.total], [5000000000, 10000000001, 10000000001])
