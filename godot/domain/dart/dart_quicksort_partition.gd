class_name DartQuicksortPartition
extends RefCounted
## The three partition loops of Dart's dual-pivot quicksort (see
## DartQuicksort), with the SDK's comparisons and exchanges in the SDK's
## order. Each works on the elements from `from` to `to` and leaves the bounds
## it reached in `less` and `great`.

## First index after the elements put on the left.
var less: int
## Last index before the elements put on the right.
var great: int

var _list: Array
var _compare: Callable


func _init(list: Array, compare: Callable) -> void:
	_list = list
	_compare = compare


## Equal pivots, a Dutch national flag: `< pivot | == pivot | > pivot`.
func flag_around(pivot: Variant, from: int, to: int) -> void:
	less = from
	great = to
	var k := from
	while k <= great:
		var ak: Variant = _list[k]
		var comp: int = _compare.call(ak, pivot)
		if comp < 0:
			_move_to_the_left(k, ak)
		elif comp > 0:
			comp = _compare.call(_list[great], pivot)
			while comp > 0:
				great -= 1
				comp = _compare.call(_list[great], pivot)
			_exchange_with_the_end(k, ak, comp < 0)
		k += 1


## `< pivot1 | pivot1 <= .. <= pivot2 | > pivot2`.
func split_between(pivot1: Variant, pivot2: Variant, from: int, to: int) -> void:
	less = from
	great = to
	var k := from
	while k <= great:
		var ak: Variant = _list[k]
		if _compare.call(ak, pivot1) < 0:
			_move_to_the_left(k, ak)
		elif _compare.call(ak, pivot2) > 0:
			while great >= k and _compare.call(_list[great], pivot2) > 0:
				great -= 1
			if great >= k:
				var comp: int = _compare.call(_list[great], pivot1)
				_exchange_with_the_end(k, ak, comp < 0)
		k += 1


## `== pivot1 | pivot1 < .. < pivot2 | == pivot2`, on a middle part that
## holds nothing outside the pivots. The SDK tests `< 0` where its comment
## says "triple exchange": with a comparator that does not lie that exchange
## never happens, and an element equal to pivot1 found at the end stays in
## the middle. Kept as it is.
func take_out_pivots(pivot1: Variant, pivot2: Variant, from: int, to: int) -> void:
	less = from
	great = to
	var k := from
	while k <= great:
		var ak: Variant = _list[k]
		if _compare.call(ak, pivot1) == 0:
			_move_to_the_left(k, ak)
		elif _compare.call(ak, pivot2) == 0:
			while great >= k and _compare.call(_list[great], pivot2) == 0:
				great -= 1
			if great >= k:
				var comp: int = _compare.call(_list[great], pivot1)
				_exchange_with_the_end(k, ak, comp < 0)
		k += 1


## Puts `ak`, found at `k`, at the end of the left part.
func _move_to_the_left(k: int, ak: Variant) -> void:
	if k != less:
		_list[k] = _list[less]
		_list[less] = ak
	less += 1


## Puts `ak`, found at `k`, at `great`. The element that was there goes to the
## left part in a triple exchange, else to `k`.
func _exchange_with_the_end(k: int, ak: Variant, triple: bool) -> void:
	if triple:
		_list[k] = _list[less]
		_list[less] = _list[great]
		less += 1
	else:
		_list[k] = _list[great]
	_list[great] = ak
	great -= 1
