class_name DartSort
extends RefCounted
## Dart's `List.sort`, which the port must follow wherever a comparator can
## tie: neither Dart's sort nor Godot's `Array.sort_custom` is stable, and
## they do not order equal elements alike. Written from the SDK's
## `internal/sort.dart` as test/tool/vectors/spec/dart_sort_spec.dart and
## held against reference/vectors/dart_sort.json, comparison for comparison.
##
## A range of up to 33 elements is sorted by insertion, which is stable; a
## longer one by DartQuicksort, which is not.
##
## Godot's own `Array.sort()` is safe on a list of whole numbers, as Dart's
## `sort()` without comparator: equal numbers cannot be told apart (section
## `natural`). `sort_custom` is safe only where no two elements can tie.

## A range is sorted by insertion while `right - left` is at most this.
const INSERTION_THRESHOLD := 32


## Sorts the list in place. `compare(a, b)` answers as Dart's `compare`: a
## negative number when a goes first, a positive one when b does, 0 for a tie.
static func sort(list: Array, compare: Callable) -> void:
	var last := list.size() - 1
	if last <= INSERTION_THRESHOLD:
		insertion_sort(list, compare, 0, last)
	else:
		DartQuicksort.new(list, compare).sort_range(0, last)


## Dart's `a.compareTo(b)` between two whole numbers: -1, 0 or 1.
static func compare_ints(a: int, b: int) -> int:
	if a < b:
		return -1
	return 1 if a > b else 0


## Sorts the elements from `left` to `right`, both included. Stable: an
## element only moves before the ones it is smaller than.
static func insertion_sort(list: Array, compare: Callable, left: int, right: int) -> void:
	for i: int in range(left + 1, right + 1):
		var element: Variant = list[i]
		var j := i
		while j > left and compare.call(list[j - 1], element) > 0:
			list[j] = list[j - 1]
			j -= 1
		list[j] = element
