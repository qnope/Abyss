class_name DartBits
extends RefCounted
## Dart's shifts where GDScript's differ, and `bitLength`, held against the
## section bits of reference/vectors/dart_math.json.
##
## `a << s` and `a >> s` are Dart's for a shift from 0 to 63, which is all
## lib/domain does (`1 << 30`, `step >>= 1`): write them as they are. They
## part beyond: Dart leaves no bit (`1 << 64` is 0), GDScript on x86 shifts
## by `s % 64` (`1 << 64` is 1). And GDScript has no `>>>`.
##
## Dart throws for a negative shift: these log an error and return 0.


## `a << shift`: 0 from 64 on.
static func shl(a: int, shift: int) -> int:
	if shift < 0:
		return _refused("shl", a, shift)
	return a << shift if shift < 64 else 0


## `a >> shift`, which keeps the sign: 0 or -1 from 64 on.
static func shr(a: int, shift: int) -> int:
	if shift < 0:
		return _refused("shr", a, shift)
	return a >> mini(shift, 63)


## `a >>> shift`, which fills with zeros: 0 from 64 on.
static func ushr(a: int, shift: int) -> int:
	if shift < 0:
		return _refused("ushr", a, shift)
	if shift == 0:
		return a
	if shift >= 64:
		return 0
	return (a >> shift) & ((1 << (64 - shift)) - 1)


## `a.bitLength`: the bits needed to write a, its sign apart: 0 for 0 and
## for -1, 8 for 255 and for -256.
static func bit_length(a: int) -> int:
	var rest := a if a >= 0 else ~a
	var length := 0
	while rest != 0:
		rest >>= 1
		length += 1
	return length


static func _refused(function: String, a: int, shift: int) -> int:
	push_error("DartBits.%s(%d, %d): the shift must not be negative" % [function, a, shift])
	return 0
