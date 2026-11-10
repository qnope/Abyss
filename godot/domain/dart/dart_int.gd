class_name DartInt
extends RefCounted
## Dart's `int.tryParse(source)`, which reads more than `String.to_int` and
## refuses more: written from the SDK's `integers_patch.dart`. No vector
## holds it yet; dart_int_test.gd lists what the Dart VM answered.
##
## The white space around is left out (Dart's, which counts the no-break
## spaces and U+FEFF), then an optional sign, then decimal digits, or `0x`
## and hexadecimal ones. A number beyond 64 bits is refused, but for a
## positive hexadecimal one of up to 16 digits, read as its bits
## (`0xFFFFFFFFFFFFFFFF` is -1).

const _MAX_DECIMAL := "9223372036854775807"
const _MIN_DECIMAL := "9223372036854775808"
const _DIGITS := "0123456789abcdef"
## The code points Dart trims, beside U+0009 to U+000D and U+2000 to U+200A.
const _SPACES: Array[int] = [
	0x20, 0x85, 0xA0, 0x1680, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000, 0xFEFF,
]


## The whole number the text writes (an int), or null.
static func try_parse(source: String) -> Variant:
	var text := _trimmed(source)
	var negative := text.begins_with("-")
	if negative or text.begins_with("+"):
		text = text.substr(1)
	var hexadecimal := text.length() > 1 and text[0] == "0" and text[1].to_lower() == "x"
	if hexadecimal:
		text = text.substr(2)
	if text.is_empty():
		return null
	var digits := text.lstrip("0").to_lower()
	var bits := 0
	for digit: String in digits:
		var value := _DIGITS.find(digit)
		if value < 0 or value >= (16 if hexadecimal else 10):
			return null
		# Counted below zero, where the smallest int fits.
		bits = (bits << 4 | value) if hexadecimal else bits * 10 - value
	if hexadecimal:
		if digits.length() > 16 or (negative and bits < 0 and bits != -bits):
			return null
		return -bits if negative else bits
	if _exceeds(digits, _MIN_DECIMAL if negative else _MAX_DECIMAL):
		return null
	return bits if negative else -bits


## Whether the decimal digits, without leading zeros, write more than the
## limit does.
static func _exceeds(digits: String, limit: String) -> bool:
	if digits.length() != limit.length():
		return digits.length() > limit.length()
	return digits > limit


static func _trimmed(source: String) -> String:
	var start := 0
	var end := source.length()
	while start < end and _is_space(source.unicode_at(start)):
		start += 1
	while end > start and _is_space(source.unicode_at(end - 1)):
		end -= 1
	return source.substr(start, end - start)


static func _is_space(code: int) -> bool:
	return (code >= 0x09 and code <= 0x0D) or (code >= 0x2000 and code <= 0x200A) or code in _SPACES
