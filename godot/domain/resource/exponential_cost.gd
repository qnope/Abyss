class_name ExponentialCost
extends RefCounted
## lib/domain/resource/exponential_cost.dart: how upgrade and research costs
## grow from one level to the next.

## Growth of upgrade and research costs from one level to the next
## (`costGrowthPerLevel`).
const COST_GROWTH_PER_LEVEL := 1.6
## The same growth as a fraction. Dart rounds `base * pow(1.6, step)`, whose
## last bit is the C library's; the port rounds the exact fraction in whole
## numbers, which gives the same costs (see DartMath.round_times_power).
const GROWTH_NUMERATOR := 8
const GROWTH_DENOMINATOR := 5


## Scales `base` by `1.6^step`, rounded to the nearest unit. `step` is 0 for
## the first level, so the first cost equals `base`. A negative step, which
## no rule asks for, logs an error and costs 0 where Dart shrinks the cost:
## nothing proves the fraction rounds as Dart's floats there.
static func exponential_cost(
	base: Dictionary[ResourceType.Value, int], step: int
) -> Dictionary[ResourceType.Value, int]:
	var cost: Dictionary[ResourceType.Value, int] = {}
	if step < 0:
		push_error("ExponentialCost.exponential_cost: the step %d is negative" % step)
	for type: ResourceType.Value in base:
		cost[type] = 0 if step < 0 else DartMath.round_times_power(
			base[type], GROWTH_NUMERATOR, GROWTH_DENOMINATOR, step
		)
	return cost
