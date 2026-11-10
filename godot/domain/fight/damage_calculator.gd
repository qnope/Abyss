class_name DamageCalculator
extends RefCounted
## lib/domain/fight/damage_calculator.dart: pure stateless utility that
## computes the damage of a single attack.

## Armour constant of the formula: a defender with this much DEF halves
## incoming damage.
const ARMOUR_CONSTANT := 10


## Computes the damage dealt by an attacker with `atk` against a defender
## with `def`.
##
## The base damage is `floor(atk * 10 / (10 + def))`, clamped to a minimum
## of `1`. `ignore_def` treats the defender as unarmoured, `multiplier`
## scales the base damage (role bonuses) and `crit` triples the result.
static func compute(
	atk: int, def: int, crit := false, ignore_def := false, multiplier := 1
) -> int:
	var effective_def := 0 if ignore_def or def < 0 else def
	var base := DartMath.trunc_div(atk * ARMOUR_CONSTANT, ARMOUR_CONSTANT + effective_def)
	if base < 1:
		base = 1
	base *= multiplier
	return base * 3 if crit else base
