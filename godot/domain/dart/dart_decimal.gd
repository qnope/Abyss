class_name DartDecimal
extends RefCounted
## Not in the Dart SDK: the exact decimal digits of a double, which
## `DartDouble` rounds as Dart's `toString` and `toStringAsFixed` do. A
## double is a whole number times a power of two, so its digits are finite:
## they come from a whole number of base 10^9 limbs (`DecimalLimbs`).


## The digits of `digits` cut to `count`, the rest rounded to the nearest
## and an exact half to the even last digit; one more digit when they carry
## (`999` to `1000`).
static func rounded(digits: String, count: int) -> String:
	if digits.length() <= count:
		return digits
	var kept := digits.substr(0, count)
	var next := digits[count]
	var beyond := not digits.substr(count + 1).replace("0", "").is_empty()
	var odd := kept[count - 1].to_int() % 2 == 1
	if next > "5" or next == "5" and (beyond or odd):
		return plus_one(kept)
	return kept


## The exact decimal digits of a whole double, beyond 64 bits too: from
## 2^62 up it is even, and halves exactly.
static func whole_digits(whole: float) -> String:
	var doublings := 0
	while whole >= 4e18:
		whole /= 2.0
		doublings += 1
	var limbs := DecimalLimbs.of(int(whole))
	DecimalLimbs.scale(limbs, 2, doublings)
	return DecimalLimbs.text_of(limbs)


## Every digit of a fraction of [0, 1): `bits / 2^k` is `bits * 5^k / 10^k`.
static func fraction_digits(fraction: float) -> String:
	if fraction == 0.0:
		return ""
	var k := 0
	while fraction != floorf(fraction):
		fraction *= 2.0
		k += 1
	var limbs := DecimalLimbs.of(int(fraction))
	DecimalLimbs.scale(limbs, 5, k)
	return DecimalLimbs.text_of(limbs).lpad(k, "0").rstrip("0")


## The decimal digits of one more than `digits`.
static func plus_one(digits: String) -> String:
	var i := digits.length() - 1
	while i >= 0 and digits[i] == "9":
		i -= 1
	if i < 0:
		return "1" + "0".repeat(digits.length())
	return digits.substr(0, i) + str(digits[i].to_int() + 1) + "0".repeat(digits.length() - 1 - i)
