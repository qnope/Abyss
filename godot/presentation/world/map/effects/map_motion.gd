class_name MapMotion
extends RefCounted
## The time of the map's effects, in seconds: the steps of a staged event and
## the curves that ease them. The interface's `AbyssMotion` holds the same
## numbers (a test in `app/` holds the two together): this layer never reads
## the interface.

## A press, a flash after a hit.
const TAP := 0.15
## A shake after a blow.
const QUICK := 0.25
## A token swimming to a neighbour cell.
const SWIM := 0.9
## One beat of a staged event: a lunge, a pulse of the alert.
const EVENT_STEP := 0.3
## Fog lifting, a defeated monster fading away.
const FADE := 0.6
## Rest between two steps of a story.
const STORY_PAUSE := 0.4


## [param cells] cells swum over: [constant SWIM] for a neighbour, longer for a
## farther cell, never more than three swims.
static func swim_over(cells: float) -> float:
	return SWIM * clampf(sqrt(cells), 1.0, 3.0)


## How far along a step [param length] long, begun at [param start], [param t]
## is, from 0 to 1. A step with no length is done as soon as it starts.
static func share(t: float, start: float, length: float) -> float:
	if length <= 0.0:
		return 1.0 if t >= start else 0.0
	return clampf((t - start) / length, 0.0, 1.0)


## Things arriving, fast then settling (easeOutCubic), at [param t] from 0 to 1.
static func enter(t: float) -> float:
	return _eased(t, Tween.EASE_OUT)


## Things leaving, slow then fast (easeInCubic).
static func exit(t: float) -> float:
	return _eased(t, Tween.EASE_IN)


## A move from one place to another (easeInOutCubic).
static func travel(t: float) -> float:
	return _eased(t, Tween.EASE_IN_OUT)


static func _eased(t: float, ease_: Tween.EaseType) -> float:
	var eased: float = Tween.interpolate_value(0.0, 1.0, clampf(t, 0.0, 1.0), 1.0, Tween.TRANS_CUBIC, ease_)
	return eased
