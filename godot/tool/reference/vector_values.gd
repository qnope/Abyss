class_name VectorValues
extends RefCounted
## The values of a vector file, as reference/vectors/README.md writes them:
## a JSON number is a whole number (Godot's JSON reads it as a float), the
## text "d:" and 16 hex digits is the float with those IEEE-754 bits, the
## text "i:" and decimal digits a whole number no float holds. decode() reads
## them, encode() writes the floats back so that an assertion compares bits.

const FLOAT_PREFIX := "d:"
const INT_PREFIX := "i:"
const NAN_BITS := "7ff8000000000000"
const HEX_DIGITS := "0123456789abcdef"
## 2^53: every whole number up to it is a float.
const MAX_EXACT := 9007199254740992.0


## What JSON.parse gave, with ints and floats where the file means them,
## through lists and maps. A malformed number logs an error and gives null.
static func decode(value: Variant) -> Variant:
	match typeof(value):
		TYPE_FLOAT:
			var number: float = value
			return _whole(number)
		TYPE_STRING:
			var text: String = value
			return _number_or_text(text)
		TYPE_ARRAY:
			var items: Array = value
			return items.map(decode)
		TYPE_DICTIONARY:
			var map: Dictionary = value
			return _mapped(map, decode)
	return value


## The value with each float as its "d:" text, through lists and maps: two
## encoded values are equal when they hold the same bits, so a NaN equals a
## NaN, 0.0 is not -0.0 and 1 is not 1.0.
static func encode(value: Variant) -> Variant:
	match typeof(value):
		TYPE_FLOAT:
			var number: float = value
			return FLOAT_PREFIX + bits_of(number)
		TYPE_ARRAY:
			var items: Array = value
			return items.map(encode)
		TYPE_DICTIONARY:
			var map: Dictionary = value
			return _mapped(map, encode)
	return value


## The float whose IEEE-754 bits are these 16 hex digits, the sign first.
static func float_of(bits: String) -> float:
	var bytes := bits.hex_decode()
	bytes.reverse()
	return bytes.decode_double(0)


## The 16 lowercase hex digits of the bits of a float; one text for every NaN.
static func bits_of(number: float) -> String:
	if is_nan(number):
		return NAN_BITS
	var bytes := PackedByteArray()
	bytes.resize(8)
	bytes.encode_double(0, number)
	bytes.reverse()
	return bytes.hex_encode()


static func _mapped(map: Dictionary, change: Callable) -> Dictionary:
	var changed := {}
	for key: Variant in map:
		changed[key] = change.call(map[key])
	return changed


static func _whole(number: float) -> Variant:
	if number != floorf(number):
		push_error("VectorValues: %s is not a whole number" % number)
		return null
	if absf(number) > MAX_EXACT:
		push_error("VectorValues: %s is beyond 2^53, it must be written i:" % number)
		return null
	return int(number)


static func _number_or_text(text: String) -> Variant:
	var digits := text.substr(2)
	if text.begins_with(INT_PREFIX):
		if digits.is_valid_int():
			return digits.to_int()
		push_error('VectorValues: "%s" is not a whole number' % text)
		return null
	if not text.begins_with(FLOAT_PREFIX):
		return text
	if digits.length() == 16 and _is_hex(digits):
		return float_of(digits)
	push_error('VectorValues: "%s" is not the 16 hex digits of a float' % text)
	return null


static func _is_hex(digits: String) -> bool:
	for digit: String in digits:
		if not HEX_DIGITS.contains(digit):
			return false
	return true
