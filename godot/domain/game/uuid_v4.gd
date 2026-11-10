class_name UuidV4
extends RefCounted
## Not in lib/domain: `const Uuid().v4()` of the `uuid` package, which draws
## the id of a player built without one. Its 122 random bits come from
## DartRandom.unseeded(): no game depends on them, a replay writes the human
## `human` (reference/README.md).

const _HEX := "0123456789abcdef"


## A random UUID of version 4, variant 1, in lowercase:
## `xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx`.
static func generate() -> String:
	var random := DartRandom.unseeded()
	var text := ""
	for index: int in 16:
		var byte := random.next_int(256)
		if index == 6:
			byte = byte & 0x0F | 0x40
		elif index == 8:
			byte = byte & 0x3F | 0x80
		if index in [4, 6, 8, 10]:
			text += "-"
		text += _HEX[byte >> 4] + _HEX[byte & 0x0F]
	return text
