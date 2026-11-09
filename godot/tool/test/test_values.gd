class_name TestValues
extends RefCounted
## How the assertions compare and show values: exactly, deep through arrays
## and dictionaries, a StringName reading as its text, and strings quoted so
## that "1" and 1 read apart.


static func equal(a: Variant, b: Variant) -> bool:
	if _is_text(a) and _is_text(b):
		return str(a) == str(b)
	if typeof(a) != typeof(b):
		return false
	match typeof(a):
		TYPE_ARRAY:
			var left: Array = a
			var right: Array = b
			return _arrays_equal(left, right)
		TYPE_DICTIONARY:
			var left: Dictionary = a
			var right: Dictionary = b
			return _dictionaries_equal(left, right)
	return a == b


static func describe(value: Variant) -> String:
	match typeof(value):
		TYPE_NIL:
			return "null"
		TYPE_STRING:
			return '"%s"' % str(value).c_escape()
		TYPE_STRING_NAME:
			return '&"%s"' % str(value).c_escape()
		TYPE_ARRAY:
			var array: Array = value
			return "[%s]" % ", ".join(PackedStringArray(array.map(describe)))
		TYPE_DICTIONARY:
			var dictionary: Dictionary = value
			var pairs := PackedStringArray()
			for key: Variant in dictionary:
				pairs.append("%s: %s" % [describe(key), describe(dictionary[key])])
			return "{%s}" % ", ".join(pairs)
	return str(value)


static func contains(container: Variant, item: Variant) -> bool:
	if _is_text(container):
		return _is_text(item) and str(container).contains(str(item))
	var kind := typeof(container)
	if kind != TYPE_ARRAY and kind != TYPE_DICTIONARY and kind < TYPE_PACKED_BYTE_ARRAY:
		return false
	for element: Variant in container:
		if equal(element, item):
			return true
	return false


static func _is_text(value: Variant) -> bool:
	return value is String or value is StringName


static func _arrays_equal(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	for index: int in a.size():
		if not equal(a[index], b[index]):
			return false
	return true


static func _dictionaries_equal(a: Dictionary, b: Dictionary) -> bool:
	if a.size() != b.size():
		return false
	for key: Variant in a:
		if not b.has(key) or not equal(a[key], b[key]):
			return false
	return true
