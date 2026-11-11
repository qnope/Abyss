class_name CanonicalWriter
extends RefCounted
## lib/domain/reference/canonical_writer.dart: writes a value as the
## canonical text of the reference games, a strict subset of JSON that the
## Dart rules and their port write byte for byte (reference/README.md):
##
## - no whitespace;
## - map keys are strings, sorted by UTF-16 code unit;
## - integers in decimal;
## - a float is never a number: it is the string `d:` followed by the 16
##   lowercase hex digits of its IEEE-754 bits, and NaN is refused;
## - a string escapes only `"`, `\` and the characters below 0x20 (as
##   `\u00xx`); everything else is written raw.


## The text of `value`. On anything but null, a bool, an int, a float, a
## String, an Array or a Dictionary with String keys, however deep, and on
## a NaN, logs an error and gives "", where Dart throws.
static func write(value: Variant) -> String:
	var out := PackedStringArray()
	if not _write(value, out):
		return ""
	return "".join(out)


static func _write(value: Variant, out: PackedStringArray) -> bool:
	match typeof(value):
		TYPE_NIL:
			out.append("null")
		TYPE_BOOL:
			out.append("true" if value else "false")
		TYPE_INT:
			out.append(str(value))
		TYPE_FLOAT:
			var number: float = value
			if is_nan(number):
				push_error("CanonicalWriter: NaN has no canonical text")
				return false
			_write_string(_double_text(number), out)
		TYPE_STRING:
			var text: String = value
			_write_string(text, out)
		TYPE_ARRAY:
			var list: Array = value
			return _write_list(list, out)
		TYPE_DICTIONARY:
			var map: Dictionary = value
			return _write_map(map, out)
		_:
			push_error("CanonicalWriter: not a canonical value (%s)" % type_string(typeof(value)))
			return false
	return true


static func _write_list(list: Array, out: PackedStringArray) -> bool:
	out.append("[")
	for i: int in list.size():
		if i > 0:
			out.append(",")
		if not _write(list[i], out):
			return false
	out.append("]")
	return true


static func _write_map(map: Dictionary, out: PackedStringArray) -> bool:
	var keys: Array[String] = []
	for key: Variant in map:
		if typeof(key) != TYPE_STRING:
			push_error("CanonicalWriter: not a canonical key (%s)" % type_string(typeof(key)))
			return false
		var text: String = key
		keys.append(text)
	CanonicalKeys.sort(keys)
	out.append("{")
	for i: int in keys.size():
		if i > 0:
			out.append(",")
		_write_string(keys[i], out)
		out.append(":")
		if not _write(map[keys[i]], out):
			return false
	out.append("}")
	return true


## `d:` and the bits of `value`, most significant first, in hex.
static func _double_text(value: float) -> String:
	var bytes := PackedByteArray()
	bytes.resize(8)
	bytes.encode_double(0, value)
	return "d:%08x%08x" % [bytes.decode_u32(4), bytes.decode_u32(0)]


static func _write_string(text: String, out: PackedStringArray) -> void:
	out.append("\"")
	if text.is_valid_ascii_identifier():
		out.append(text)
		out.append("\"")
		return
	var written := 0
	for i: int in text.length():
		var unit := text.unicode_at(i)
		if unit >= 0x20 and unit != 0x22 and unit != 0x5c:
			continue
		out.append(text.substr(written, i - written))
		written = i + 1
		match unit:
			0x22:
				out.append("\\\"")
			0x5c:
				out.append("\\\\")
			_:
				out.append("\\u00%02x" % unit)
	out.append(text.substr(written))
	out.append("\"")
