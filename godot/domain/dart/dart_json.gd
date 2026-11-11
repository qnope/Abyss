class_name DartJson
extends RefCounted
## Dart's `jsonEncode(value)` and `JsonEncoder.withIndent(indent)
## .convert(value)`, which `JSON.stringify` writes otherwise: a map keeps
## the order of its keys, a double is its Dart text (`DartDouble`, `2.0`
## where Godot writes `2`), and a string escapes what Dart escapes. No
## vector holds it yet; dart_json_test.gd lists what the Dart VM wrote.
##
## Where Dart throws (a NaN or an infinity, a key that is no String, a value
## JSON has no form for), logs an error and gives "".

const _ESCAPES: Dictionary[int, String] = {
	0x22: "\\\"", 0x5C: "\\\\", 0x08: "\\b", 0x09: "\\t", 0x0A: "\\n", 0x0C: "\\f", 0x0D: "\\r",
}


## The JSON text of `value`, on one line, or indented by `indent` per level
## when it is not empty.
static func encode(value: Variant, indent := "") -> String:
	var out := PackedStringArray()
	if not _write(value, indent, 0, out):
		return ""
	return "".join(out)


static func _write(value: Variant, indent: String, depth: int, out: PackedStringArray) -> bool:
	match typeof(value):
		TYPE_NIL:
			out.append("null")
		TYPE_BOOL:
			out.append("true" if value else "false")
		TYPE_INT:
			out.append(str(value))
		TYPE_FLOAT:
			var number: float = value
			if is_nan(number) or is_inf(number):
				push_error("DartJson: %s has no JSON form" % DartDouble.text_of(number))
				return false
			out.append(DartDouble.text_of(number))
		TYPE_STRING:
			var text: String = value
			out.append(_quoted(text))
		TYPE_ARRAY:
			var items: Array = value
			return _write_items(items, [], false, indent, depth, out)
		TYPE_DICTIONARY:
			var map: Dictionary = value
			for key: Variant in map:
				if typeof(key) != TYPE_STRING:
					push_error("DartJson: a key must be a String, not %s" % type_string(typeof(key)))
					return false
			return _write_items(map.values(), map.keys(), true, indent, depth, out)
		_:
			push_error("DartJson: %s has no JSON form" % type_string(typeof(value)))
			return false
	return true


## The items of a list, or the values of a map with their `keys`.
static func _write_items(
	items: Array, keys: Array, is_map: bool, indent: String, depth: int, out: PackedStringArray,
) -> bool:
	var open := "{" if is_map else "["
	var close := "}" if is_map else "]"
	if items.is_empty():
		out.append(open + close)
		return true
	out.append(open)
	for i: int in items.size():
		if i > 0:
			out.append(",")
		if not indent.is_empty():
			out.append("\n" + indent.repeat(depth + 1))
		if is_map:
			var key: String = keys[i]
			out.append(_quoted(key) + (": " if not indent.is_empty() else ":"))
		if not _write(items[i], indent, depth + 1, out):
			return false
	if not indent.is_empty():
		out.append("\n" + indent.repeat(depth))
	out.append(close)
	return true


static func _quoted(text: String) -> String:
	var out := PackedStringArray(["\""])
	for i: int in text.length():
		var code := text.unicode_at(i)
		if _ESCAPES.has(code):
			out.append(_ESCAPES[code])
		elif code < 0x20:
			out.append("\\u%04x" % code)
		else:
			out.append(text[i])
	out.append("\"")
	return "".join(out)
