class_name SiegeTimeline
extends RefCounted
## When each step of a siege happens (lib/presentation/widgets/map/effects/story/
## siege_timeline.dart): an alert rings around the place besieged, the attackers
## close in, clash with its defenders once per round of the fight, the outcome
## lands (they are pushed back, or they break in), then the map rests a moment.

## The alert ringing twice around the place.
const ALERT := MapMotion.EVENT_STEP * 2.0
## The attackers closing in.
const APPROACH := MapMotion.SWIM
## The attackers pushed back, or breaking in.
const OUTCOME := MapMotion.FADE
## The rest before what comes next.
const REST := MapMotion.STORY_PAUSE

## Number of rounds of the fight, one clash each.
var rounds: int


func _init(rounds_ := 0) -> void:
	rounds = rounds_


## The clashes, once the attackers are close.
func clashes() -> FightPace:
	return FightPace.new(ALERT + APPROACH, rounds)


## When the outcome lands, after the last clash.
func impact() -> float:
	return clashes().end()


## How long the whole siege lasts.
func total() -> float:
	return impact() + OUTCOME + REST


## How bright the alert is at [param t]: two pulses, then nothing.
func alert_at(t: float) -> float:
	if t >= ALERT:
		return 0.0
	return absf(sin(2.0 * PI * MapMotion.share(t, 0.0, ALERT)))


## How far the attackers have closed in at [param t], from 0 to 1.
func approach_at(t: float) -> float:
	return MapMotion.share(t, ALERT, APPROACH)


## How far along the outcome is at [param t], from 0 to 1.
func outcome_at(t: float) -> float:
	return MapMotion.share(t, impact(), OUTCOME)
