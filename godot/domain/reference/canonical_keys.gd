class_name CanonicalKeys
extends RefCounted
## Not in the Dart class: the order of the keys of a canonical map, Dart's
## `String.compareTo`, which compares UTF-16 code units. GDScript compares
## code points: the two agree but where a character above U+FFFF, two
## units from U+D800 up, meets one from U+E000 to U+FFFF. Keys are distinct,
## so no two tie.


## Sorts `keys` in place, by UTF-16 code unit.
static func sort(keys: Array[String]) -> void:
	keys.sort()
	var joined := "".join(keys)
	if joined.to_utf16_buffer().size() != 2 * joined.length():
		DartSort.sort(keys, compare)


## `a.compareTo(b)`: unit by unit, the shorter first when one starts the
## other.
static func compare(a: String, b: String) -> int:
	var left := a.to_utf16_buffer()
	var right := b.to_utf16_buffer()
	for i: int in range(0, mini(left.size(), right.size()), 2):
		var unit := left.decode_u16(i) - right.decode_u16(i)
		if unit != 0:
			return unit
	return left.size() - right.size()
