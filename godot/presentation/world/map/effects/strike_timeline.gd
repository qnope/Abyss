class_name StrikeTimeline
extends RefCounted
## When each step of an attack on a lair happens (lib/presentation/widgets/map/
## effects/strike/strike_timeline.dart): the army swims next to the lair, lunges
## at it once per hit, the outcome settles (the monster dies, or the army
## retreats), then the army vanishes. A long fight lunges faster, so its hits
## keep within [constant FightPace.ROUNDS_BUDGET].

## The defeated monster fading away, or the army retreating.
const OUTCOME := MapMotion.FADE
## The army fading out at the end.
const VANISH := MapMotion.QUICK

## The swim next to the lair, in seconds; nothing when the army starts there.
var swim: float
## Number of lunges.
var hits: int


func _init(swim_: float, hits_: int) -> void:
	swim = swim_
	hits = hits_


## The lunges at the lair, once the army is beside it.
func pace() -> FightPace:
	return FightPace.new(swim, hits)


## How long the whole attack lasts.
func total() -> float:
	return pace().end() + OUTCOME + VANISH


## When hit [param index] lands, at the peak of its lunge.
func hit_at(index: int) -> float:
	return pace().hit_at(index)


## How far along the swim is at [param t], from 0 to 1.
func swim_at(t: float) -> float:
	return MapMotion.share(t, 0.0, swim)


## How far forward a lunge reaches at [param t]: 0 at rest, 1 at its peak.
func reach_at(t: float) -> float:
	return pace().reach_at(t)


## How far along the outcome is at [param t], from 0 to 1.
func outcome_at(t: float) -> float:
	return MapMotion.share(t, pace().end(), OUTCOME)


## How far the army has vanished at [param t], from 0 to 1.
func vanish_at(t: float) -> float:
	return MapMotion.share(t, pace().end() + OUTCOME, VANISH)
