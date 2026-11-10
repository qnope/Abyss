class_name DartMath
extends RefCounted
## Dart's arithmetic where GDScript's differs, for the rules ported from
## lib/domain: each function answers as the Dart VM does, held against
## reference/vectors/dart_math.json.
##
## - `a ~/ b` is trunc_div(a, b). GDScript's `/` between two ints gives the
##   same number, but it reads as Dart's `/`, and it crashes the engine on
##   the smallest int divided by -1.
## - `a % b` is modulo(a, b): never negative in Dart, of the sign of `a` in
##   GDScript, and `posmod` is wrong for a negative `b`.
## - `a / b` between two ints is quotient(a, b), a float: 7 / 2 is 3.5.
## - `x.round()`, `floor()`, `ceil()`, `truncate()` and `toInt()` stop at the
##   ends of 64 bits here. `roundi`, `floori`, `ceili` and `int()` are Dart's
##   inside them; from 2^63 up they depend on the processor.
## - `pow`: int_pow() for whole numbers, round_times_power() for a cost that
##   grows by a ratio. Never `pow()` nor `**`, see them.
##
## What GDScript does as Dart, and a rule writes as it is, is listed in
## README.md and checked in dart_native_test.gd and dart_native_float_test.gd.
##
## Where Dart throws (a division by zero, a NaN to round), the function logs
## an error and returns 0: GDScript has no exceptions, and no rule may rely on
## what Dart never returned.

const MAX_INT := 9223372036854775807
const MIN_INT := -9223372036854775807 - 1
## 2^63, the first float no int holds.
const _TWO_POW_63 := 9223372036854775808.0
const _TWO_POW_52 := 4503599627370496.0


## `a ~/ b`: the quotient without its fraction, towards zero.
static func trunc_div(a: int, b: int) -> int:
	if b == 0:
		push_error("DartMath.trunc_div(%d, 0): division by zero" % a)
		return 0
	if b == -1:
		return -a
	@warning_ignore("integer_division")
	return a / b


## `a % b`: what is left of `a` once the multiples of `b` are taken out,
## from 0 to |b| - 1.
static func modulo(a: int, b: int) -> int:
	if b == 0:
		push_error("DartMath.modulo(%d, 0): division by zero" % a)
		return 0
	if b == -1:
		return 0
	var rest := a % b
	if rest >= 0:
		return rest
	return rest - b if b < 0 else rest + b


## `a / b` between two whole numbers: a float, infinite or NaN when b is 0.
static func quotient(a: int, b: int) -> float:
	return float(a) / float(b)


## `x.round()`: the nearest whole number, a half going away from zero.
static func round(x: float) -> int:
	return to_int(roundf(x))


## `x.floor()`: the largest whole number not above x.
static func floor(x: float) -> int:
	return to_int(floorf(x))


## `x.ceil()`: the smallest whole number not below x.
static func ceil(x: float) -> int:
	return to_int(ceilf(x))


## `x.truncate()`, which is `x.toInt()`.
static func truncate(x: float) -> int:
	return to_int(x)


## `x.toInt()`: x without its fraction; MAX_INT or MIN_INT beyond 64 bits.
static func to_int(x: float) -> int:
	if not is_finite(x):
		push_error("DartMath: %s has no whole number" % x)
		return 0
	if x >= _TWO_POW_63:
		return MAX_INT
	if x <= -_TWO_POW_63:
		return MIN_INT
	return int(x)


## `pow(base, exponent)` of dart:math between two whole numbers, for an
## exponent of 0 or more: a whole number, wrapping to 64 bits. GDScript's
## `**` does not wrap, and `pow()` gives a float.
static func int_pow(base: int, exponent: int) -> int:
	if exponent < 0:
		push_error("DartMath.int_pow(%d, %d): Dart gives a double" % [base, exponent])
		return 0
	var result := 1
	var factor := base
	var left := exponent
	while left > 0:
		if left & 1 == 1:
			result *= factor
		factor *= factor
		left >>= 1
	return result


## `(base * pow(numerator / denominator, exponent)).round()` without `pow`,
## whose last bit is the C library's and changes from a machine to another:
## the exact rounding, in whole numbers. Dart's `exponentialCost(base, step)`,
## which grows a cost by 1.6 a level, is round_times_power(base, 8, 5, step).
## Dart's floats give the same number while base * numerator^exponent *
## (exponent + 2) is below 2^52 (a cost of 3 million at step 9), the nearest
## half being then too far for their error to cross it; beyond, this logs an
## error, as nothing proves the two agree.
static func round_times_power(
	base: int, numerator: int, denominator: int, exponent: int
) -> int:
	var size := absi(base)
	if size * pow(numerator, exponent) * (exponent + 2) >= _TWO_POW_52:
		push_error(
			"DartMath.round_times_power(%d, %d, %d, %d): too large to round as Dart for sure"
			% [base, numerator, denominator, exponent]
		)
	var divisor := int_pow(denominator, exponent)
	@warning_ignore("integer_division")
	var rounded := (2 * size * int_pow(numerator, exponent) + divisor) / (2 * divisor)
	return rounded if base >= 0 else -rounded
