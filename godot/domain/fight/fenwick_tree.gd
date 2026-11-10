class_name FenwickTree
extends RefCounted
## lib/domain/fight/fenwick_tree.dart: binary indexed tree over `size`
## positions holding integer counts.
##
## Point updates, prefix sums and the lookup of the position holding the
## n-th unit of count all run in O(log size), which keeps a random pick
## among a shrinking set cheap without rebuilding a filtered list.

## Number of positions, `0` to `size - 1`.
var size: int
## Sum of every count: `_total` behind a getter in Dart, a field here so that
## the fight reads it without a call.
var total := 0

## Plain counts per position, for O(1) point reads.
var _counts := PackedInt64Array()
## Fenwick nodes, 1-based.
var _nodes := PackedInt64Array()
## Largest power of two at most `size`: the first lifting step.
var _top_step: int


func _init(size_: int) -> void:
	size = size_
	_counts.resize(size)
	_nodes.resize(size + 1)
	_top_step = 0 if size == 0 else 1 << (DartBits.bit_length(size) - 1)


## `FenwickTree.fromCounts`: a tree holding `counts`, one per position, built
## in O(size) instead of one O(log size) `add` per position. Node `i` is
## complete once every lower node has been visited, so it is pushed up to
## the node above it.
static func from_counts(counts: PackedInt64Array) -> FenwickTree:
	var tree := FenwickTree.new(counts.size())
	tree._counts = counts.duplicate()
	var nodes := tree._nodes
	var sum := 0
	for i: int in range(1, tree.size + 1):
		var count := counts[i - 1]
		sum += count
		nodes[i] += count
		var parent := i + (i & -i)
		if parent <= tree.size:
			nodes[parent] += nodes[i]
	tree.total = sum
	return tree


## Count held at `position`.
func at(position: int) -> int:
	return _counts[position]


## Adds `delta` to the count at `position`.
func add(position: int, delta: int) -> void:
	_counts[position] += delta
	total += delta
	var i := position + 1
	while i <= size:
		_nodes[i] += delta
		i += i & -i


## Sum of the counts at positions strictly before `end`.
func prefix(end: int) -> int:
	var sum := 0
	var i := end
	while i > 0:
		sum += _nodes[i]
		i -= i & -i
	return sum


## Position holding the `n`-th unit of count, 0-based: the first one whose
## prefix sum exceeds `n`. `n` must be below `total`.
func position_of_nth(n: int) -> int:
	var position := 0
	var remaining := n + 1
	var step := _top_step
	while step > 0:
		var next := position + step
		if next <= size and _nodes[next] < remaining:
			position = next
			remaining -= _nodes[next]
		step >>= 1
	return position
