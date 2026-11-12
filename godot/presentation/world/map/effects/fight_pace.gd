class_name FightPace
extends RefCounted
## The pace of a fight played on the map from [member start]: one lunge per
## round, each hit landing at the peak of its lunge (lib/presentation/widgets/
## map/effects/strike/fight_pace.dart). A long fight lunges faster, so its
## rounds keep within [constant ROUNDS_BUDGET]. A time "since" a hit that has
## not landed yet is [constant NONE].

## The usual lunge: forward and back.
const USUAL_LUNGE := MapMotion.EVENT_STEP
## The quickest lunge of a very long fight.
const QUICKEST_LUNGE := 0.12
## How long the lunges of a long fight last together.
const ROUNDS_BUDGET := 4.0
## "Since" a hit that has not landed.
const NONE := -1.0

## When the first lunge sets off.
var start: float
## Number of rounds, one lunge each.
var rounds: int


func _init(start_: float, rounds_: int) -> void:
	start = start_
	rounds = rounds_


## The lunge of a fight of [param count] rounds: the usual one, shortened in a
## long fight so its rounds keep within [constant ROUNDS_BUDGET].
static func lunge_for(count: int) -> float:
	if count == 0 or USUAL_LUNGE * count <= ROUNDS_BUDGET:
		return USUAL_LUNGE
	return maxf(ROUNDS_BUDGET / count, QUICKEST_LUNGE)


## One lunge of this fight.
func lunge() -> float:
	return lunge_for(rounds)


## When the last lunge is over.
func end() -> float:
	return start + lunge() * rounds


## When hit [param index] lands, at the peak of its lunge.
func hit_at(index: int) -> float:
	return start + lunge() * index + lunge() / 2.0


## How far forward a lunge reaches at [param t]: 0 at rest, 1 at its peak.
func reach_at(t: float) -> float:
	if t < start or t >= end():
		return 0.0
	return sin(PI * fposmod(t - start, lunge()) / lunge())


## How long ago hit [param index] landed at [param t], [constant NONE] before it.
func since_hit(index: int, t: float) -> float:
	var since := t - hit_at(index)
	return NONE if since < 0.0 else since


## How long ago the latest hit landed at [param t], [constant NONE] before the
## first.
func since_last_hit(t: float) -> float:
	for index in range(rounds - 1, -1, -1):
		var since := since_hit(index, t)
		if since != NONE:
			return since
	return NONE


## Whether hit [param index] still shows at [param t]: from when it lands until
## the next one does, a fade at most.
func shows_hit(index: int, t: float) -> bool:
	var since := since_hit(index, t)
	if since == NONE or since >= MapMotion.FADE:
		return false
	return index + 1 >= rounds or since_hit(index + 1, t) == NONE


## How far hit [param index] has gone through its fade at [param t], from 0 as it
## lands; [constant NONE] before it lands.
func fade_of(index: int, t: float) -> float:
	var since := since_hit(index, t)
	return NONE if since == NONE else since / MapMotion.FADE
