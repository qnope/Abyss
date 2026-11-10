class_name DartQuicksort
extends RefCounted
## The dual-pivot quicksort Dart's `List.sort` runs on more than 33 elements,
## comparison for comparison (see DartSort): not stable, and the port must
## leave equal elements exactly where Dart leaves them.
##
## Five samples go through a network of nine compare-and-swaps; the second
## and the fourth are the pivots. Equal pivots give a three-way partition
## around one value, different ones `< pivot1 | between | > pivot2`. The left
## and right parts are sorted first, then the middle, the elements equal to a
## pivot taken out of it when it covers more than two thirds of the range.

## The pairs of samples compared, and swapped when out of order, in order.
const NETWORK: Array[int] = [0, 1, 3, 4, 0, 2, 1, 2, 0, 3, 2, 3, 1, 4, 1, 2, 3, 4]

var _list: Array
var _compare: Callable
var _partition: DartQuicksortPartition


func _init(list: Array, compare: Callable) -> void:
	_list = list
	_compare = compare
	_partition = DartQuicksortPartition.new(list, compare)


## Sorts the elements from `left` to `right`, both included.
func sort_range(left: int, right: int) -> void:
	if right - left <= DartSort.INSERTION_THRESHOLD:
		DartSort.insertion_sort(_list, _compare, left, right)
	else:
		_dual_pivot(left, right)


func _dual_pivot(left: int, right: int) -> void:
	@warning_ignore("integer_division")
	var sixth := (right - left + 1) / 6
	var index1 := left + sixth
	var index5 := right - sixth
	@warning_ignore("integer_division")
	var index3 := (left + right) / 2
	var index2 := index3 - sixth
	var index4 := index3 + sixth
	var five := _sorted_five(
		[_list[index1], _list[index2], _list[index3], _list[index4], _list[index5]]
	)
	var pivot1: Variant = five[1]
	var pivot2: Variant = five[3]
	_list[index1] = five[0]
	_list[index3] = five[2]
	_list[index5] = five[4]
	_list[index2] = _list[left]
	_list[index4] = _list[right]

	var pivots_are_equal: bool = _compare.call(pivot1, pivot2) == 0
	if pivots_are_equal:
		_partition.flag_around(pivot1, left + 1, right - 1)
	else:
		_partition.split_between(pivot1, pivot2, left + 1, right - 1)
	var less := _partition.less
	var great := _partition.great

	_list[left] = _list[less - 1]
	_list[less - 1] = pivot1
	_list[right] = _list[great + 1]
	_list[great + 1] = pivot2
	sort_range(left, less - 2)
	sort_range(great + 2, right)
	if pivots_are_equal:
		return

	if less < index1 and great > index5:
		while _compare.call(_list[less], pivot1) == 0:
			less += 1
		while _compare.call(_list[great], pivot2) == 0:
			great -= 1
		_partition.take_out_pivots(pivot1, pivot2, less, great)
		less = _partition.less
		great = _partition.great
	sort_range(less, great)


func _sorted_five(samples: Array) -> Array:
	for pair: int in range(0, NETWORK.size(), 2):
		var i := NETWORK[pair]
		var j := NETWORK[pair + 1]
		if _compare.call(samples[i], samples[j]) > 0:
			var swapped: Variant = samples[i]
			samples[i] = samples[j]
			samples[j] = swapped
	return samples
