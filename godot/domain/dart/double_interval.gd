class_name DoubleInterval
extends RefCounted
## Not in the Dart SDK: the reals that read back as a positive finite double,
## the nearest double taken and a half going to the even mantissa, for
## `DartDouble.text_of` to find the shortest digits of a double as Dart's
## `toString` does.
##
## The double is `m * 2^e`; its interval runs from halfway to the double
## below to halfway to the one above: `(4m - 2) * 2^(e - 2)` to
## `(4m + 2) * 2^(e - 2)`, `4m - 1` below a power of two, where the double
## below is nearer.

var _low: Array[int]
var _high: Array[int]
## The power of two the bounds are times.
var _shift: int
## Whether the bounds read back as the double: its mantissa is even.
var _closed: bool


func _init(size: float) -> void:
	var bytes := PackedByteArray()
	bytes.resize(8)
	bytes.encode_double(0, size)
	var bits := bytes.decode_s64(0)
	var exponent := bits >> 52
	var fraction := bits & 0xFFFFFFFFFFFFF
	var mantissa := fraction if exponent == 0 else fraction + (1 << 52)
	var nearer_below := fraction == 0 and exponent > 1
	_low = DecimalLimbs.of(4 * mantissa - (1 if nearer_below else 2))
	_high = DecimalLimbs.of(4 * mantissa + 2)
	_shift = (-1074 if exponent == 0 else exponent - 1075) - 2
	_closed = mantissa % 2 == 0


## -1, 0 or 1 as `digits` (up to 18) times ten to the `exponent` lies below
## the interval, in it or above it.
func place(digits: String, exponent: int) -> int:
	var below := _compare(digits, exponent, _low)
	if below < 0 or below == 0 and not _closed:
		return -1
	var above := _compare(digits, exponent, _high)
	if above > 0 or above == 0 and not _closed:
		return 1
	return 0


func _compare(digits: String, exponent: int, bound: Array[int]) -> int:
	var value := DecimalLimbs.of(digits.to_int())
	var limit: Array[int] = bound.duplicate()
	DecimalLimbs.scale(value if exponent >= 0 else limit, 10, absi(exponent))
	DecimalLimbs.scale(limit if _shift >= 0 else value, 2, absi(_shift))
	return DecimalLimbs.compare(value, limit)
