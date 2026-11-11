class_name DartDouble
extends RefCounted
## Dart's texts of a double, which GDScript writes otherwise: `x.toString()`
## (`$x` in a string, a double of `jsonEncode`) and `x.toStringAsFixed(n)`.
## No vector holds them yet; dart_double_test.gd lists what the Dart VM
## answered.
##
## `toString` writes the fewest digits that read back as the same double
## (`DoubleInterval`), the nearest to it, an exact half to the even digit,
## in Dart's layout: `1.0`, `0.000001`, `1e-7`, `123456789012345680000.0`,
## `1e+21`, `NaN`, `-Infinity`. `String.num_scientific` writes up to 17
## digits where 16 do (`53114054046121984` for Dart's `53114054046121980.0`).
## `toStringAsFixed` rounds the exact binary value, an exact half away from
## zero (`0.25` to `0.3`, `2.5` to `3`), where `"%.1f"` rounds it to even.

## Digits that always read back as the double they were rounded from.
const _ENOUGH := 17


## Dart's `x.toString()`: `to_string` is a method of every Godot object.
static func text_of(x: float) -> String:
	if is_nan(x):
		return "NaN"
	if is_inf(x):
		return "Infinity" if x > 0 else "-Infinity"
	if x == 0.0:
		return "-0.0" if _negative(x) else "0.0"
	var sign := "-" if x < 0 else ""
	var size := absf(x)
	var whole := floorf(size)
	var exact := DartDecimal.whole_digits(whole) if whole > 0 else ""
	var point := exact.length()
	exact += DartDecimal.fraction_digits(size - whole)
	while exact.begins_with("0"):
		exact = exact.substr(1)
		point -= 1
	var interval := DoubleInterval.new(size)
	var count := 1
	var digits := _shortest(exact, count, point, interval)
	while digits.is_empty():
		count += 1
		digits = _shortest(exact, count, point, interval)
	point += digits.length() - count
	digits = digits.rstrip("0")
	# As double-conversion's ToShortest: digits from 10^-6 to 10^20.
	if point > -6 and point <= 21:
		return sign + _decimal(digits, point)
	var rest := "." + digits.substr(1) if digits.length() > 1 else ""
	return "%s%s%se%s%d" % [sign, digits[0], rest, "+" if point > 0 else "-", absi(point - 1)]


## Dart's `x.toStringAsFixed(fraction_digits)`, for 0 to 20 digits.
static func text_as_fixed(x: float, fraction_digits: int) -> String:
	if fraction_digits < 0 or fraction_digits > 20:
		push_error("DartDouble: %d fraction digits, out of 0..20" % fraction_digits)
		return ""
	if is_nan(x) or absf(x) >= 1e21:
		return text_of(x)
	var sign := "-" if _negative(x) else ""
	var size := absf(x)
	var whole := floorf(size)
	var fraction := DartDecimal.fraction_digits(size - whole).rpad(fraction_digits + 1, "0")
	var kept := DartDecimal.whole_digits(whole) + fraction.substr(0, fraction_digits)
	if fraction[fraction_digits] >= "5":
		kept = DartDecimal.plus_one(kept)
	var cut := kept.length() - fraction_digits
	if fraction_digits == 0:
		return sign + kept
	return sign + kept.substr(0, cut) + "." + kept.substr(cut)


## `count` digits of a double that read back as it, or "" when none does:
## its first `count` exact digits (`0.exact` times ten to the `point`, the
## first not 0) or the next number up, the nearer when both do, rounded as
## `DartDecimal.rounded`. One more digit when the number up carries. The
## nearer alone would not do beside a power of two, whose interval is wider
## above: the number up may read back where the nearer, below, does not.
static func _shortest(exact: String, count: int, point: int, interval: DoubleInterval) -> String:
	var padded := exact.rpad(count, "0")
	if count >= _ENOUGH:
		return DartDecimal.rounded(padded, count)
	var down := padded.substr(0, count)
	var up := DartDecimal.plus_one(down)
	var fits_down := interval.place(down, point - count) == 0
	var fits_up := interval.place(up, point - count) == 0
	if fits_down and fits_up:
		return DartDecimal.rounded(padded, count)
	return down if fits_down else up if fits_up else ""


## `0.DIGITS` times ten to the `point`, written out.
static func _decimal(digits: String, point: int) -> String:
	if point <= 0:
		return "0." + "0".repeat(-point) + digits
	if point >= digits.length():
		return digits + "0".repeat(point - digits.length()) + ".0"
	return digits.substr(0, point) + "." + digits.substr(point)


static func _negative(x: float) -> bool:
	var bytes := PackedByteArray()
	bytes.resize(8)
	bytes.encode_double(0, x)
	return bytes[7] >= 0x80
