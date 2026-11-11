class_name DecimalLimbs
extends RefCounted
## Not in the Dart SDK: whole numbers of any size from 0 up, as `Array[int]`
## of base 10^9 limbs, the lowest first, for the exact digits and bounds of
## a double (`DartDecimal`, `DoubleInterval`).

const _LIMB := 1000000000
## The largest power of each base a step of `scale` multiplies by: its
## product with a limb stays within 64 bits.
const _STEPS: Dictionary[int, int] = {2: 27, 5: 11, 10: 8}


## The limbs of `number`, 0 or more.
static func of(number: int) -> Array[int]:
	var limbs: Array[int] = [number % _LIMB]
	number = DartMath.trunc_div(number, _LIMB)
	while number > 0:
		limbs.append(number % _LIMB)
		number = DartMath.trunc_div(number, _LIMB)
	return limbs


## The decimal digits of `limbs`.
static func text_of(limbs: Array[int]) -> String:
	var text := str(limbs[limbs.size() - 1])
	for i: int in range(limbs.size() - 2, -1, -1):
		text += str(limbs[i]).lpad(9, "0")
	return text


## Multiplies `limbs` in place by `factor`, up to 10^9.
static func multiply(limbs: Array[int], factor: int) -> void:
	var carry := 0
	for i: int in limbs.size():
		var product := limbs[i] * factor + carry
		limbs[i] = product % _LIMB
		carry = DartMath.trunc_div(product, _LIMB)
	while carry > 0:
		limbs.append(carry % _LIMB)
		carry = DartMath.trunc_div(carry, _LIMB)


## Multiplies `limbs` in place by `base` (2, 5 or 10) to the `exponent`.
static func scale(limbs: Array[int], base: int, exponent: int) -> void:
	var step: int = _STEPS[base]
	while exponent > 0:
		var power := mini(exponent, step)
		multiply(limbs, DartMath.int_pow(base, power))
		exponent -= power


## -1, 0 or 1 as `a` is below, equal to or above `b`.
## Neither has a zero limb on top, as `of` and `multiply` make them.
static func compare(a: Array[int], b: Array[int]) -> int:
	if a.size() != b.size():
		return -1 if a.size() < b.size() else 1
	for i: int in range(a.size() - 1, -1, -1):
		if a[i] != b[i]:
			return -1 if a[i] < b[i] else 1
	return 0
