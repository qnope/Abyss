class_name DartNum
extends RefCounted
## Dart's `min`, `max`, `clamp` and `compareTo` between numbers of either
## type, an int or a float in a Variant: they return one of their operands
## as it is, so an int stays an int. Written from the SDK (`math_patch.dart`,
## `double.dart`, `integers.dart`) and held against the sections minMax and
## clamp of reference/vectors/dart_math.json.
##
## Between two ints, `mini`, `maxi` and `clampi` are Dart's: use them (see
## dart_native_test.gd). Godot's `min`, `max` and `clamp`, and `minf`, `maxf`
## and `clampf`, part from Dart on a zero, whose sign they ignore, and on a
## NaN: these are for the rules that can meet one, or that sort floats.
##
## Dart's `clamp` throws when the bounds are out of order: this one logs an
## error and returns 0.

const _TWO_POW_63 := 9223372036854775808.0
## 2^53: up to it, every whole number is a float.
const _MAX_EXACT := 9007199254740992


## `min(a, b)` of dart:math: the first of two equal numbers, -0.0 rather
## than 0.0, a NaN if there is one.
static func min(a: Variant, b: Variant) -> Variant:
	if a > b:
		return b
	if a < b or b is int:
		return a
	var other: float = b
	if a is float and a == 0.0:
		var zero: float = a
		return (zero + other) * zero * other
	return b if (a == 0 and _is_negative(b)) or is_nan(other) else a


## `max(a, b)` of dart:math: the first of two equal numbers, 0.0 rather than
## -0.0, a NaN if there is one.
static func max(a: Variant, b: Variant) -> Variant:
	if a > b:
		return a
	if a < b:
		return b
	if b is int:
		return b if b == 0 and _is_negative(a) else a
	var other: float = b
	if a is float and a == 0.0:
		var zero: float = a
		return zero + other
	return b if is_nan(other) else a


## `x.clamp(low, high)`: low when x is before it, high when x is after it.
static func clamp(x: Variant, low: Variant, high: Variant) -> Variant:
	if compare_to(low, high) > 0:
		push_error("DartNum.clamp(%s, %s, %s): the bounds are out of order" % [x, low, high])
		return 0
	if _is_nan(low):
		return low
	var is_before: bool = x < low if x is int else compare_to(x, low) < 0
	if is_before:
		return low
	return high if compare_to(x, high) > 0 else x


## `a.compareTo(b)`: -1, 0 or 1. Floats go from -infinity to infinity, -0.0
## before 0.0, and a NaN after everything; a whole number and a float are
## compared exactly, beyond 2^53 too.
static func compare_to(a: Variant, b: Variant) -> int:
	if a is float:
		var x: float = a
		return _compare_float(x, b)
	var whole: int = a
	if b is int:
		var other_whole: int = b
		return DartSort.compare_ints(whole, other_whole)
	var other: float = b
	if other < -_TWO_POW_63:
		return 1
	if other >= _TWO_POW_63 or is_nan(other):
		return -1
	if _is_exact(whole):
		return -_compare_float(other, float(whole))
	return DartSort.compare_ints(whole, int(other))


static func _compare_float(x: float, other: Variant) -> int:
	if x < other:
		return -1
	if x > other:
		return 1
	if x != other:
		if is_nan(x):
			return 0 if _is_nan(other) else 1
		return -1
	if x == 0.0:
		return int(_is_negative(other)) - int(_is_negative(x))
	if other is float:
		return 0
	var whole: int = other
	if _is_exact(whole):
		return 0
	return 1 if x >= _TWO_POW_63 else DartSort.compare_ints(int(x), whole)


## Whether a float holds this whole number for sure: up to 2^53 either way.
static func _is_exact(whole: int) -> bool:
	return -_MAX_EXACT <= whole and whole <= _MAX_EXACT


## Dart's `isNegative`: below zero, or the zero with a minus sign.
static func _is_negative(number: Variant) -> bool:
	if number is int:
		return number < 0
	var x: float = number
	return x < 0.0 or (x == 0.0 and 1.0 / x < 0.0)


static func _is_nan(number: Variant) -> bool:
	if number is int:
		return false
	var x: float = number
	return is_nan(x)
