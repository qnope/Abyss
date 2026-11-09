class_name AbyssMotion
## Durations and curves of every animation of the game, so the sea moves
## with one rhythm. Ported from lib/presentation/theme/abyss_motion.dart,
## durations in seconds, as Tween takes them.
##
## Three families: short feedback answering a touch, slow ambient cycles
## that make the world breathe, and the steps of a staged event (a scout
## swimming, a fight, the story of a turn).

# Short feedback.

## A press, a highlight: barely noticed.
const TAP := 0.15
## A counter bouncing, a value appearing.
const QUICK := 0.25
## A change worth a glance, such as a floating "+N".
const EMPHASIS := 0.4
## A recruit falling onto its squad's drill pad.
const RECRUIT_ARRIVAL := 0.9
## A "+N" or "−N" rising from a value that changed, then fading.
const DELTA_FLOAT := 1.2

# Ambient cycles: each divides AMBIENT_LOOP, so they all loop together.

## A creature floating up and down.
const BOB_CYCLE := 4.0
## A building swelling and settling.
const BREATHE_CYCLE := 5.0
## A wreck or a weed leaning from side to side.
const SWAY_CYCLE := 6.0
## A glow brightening and dimming.
const PULSE_CYCLE := 3.0
## A bubble rising from a working building.
const BUBBLE_CYCLE := 3.0
## A living creature undulating its tentacles or tail once.
const SWIM_CYCLE := 2.0
## Every ambient cycle.
const AMBIENT_CYCLES: Array[float] = [
	BOB_CYCLE, BREATHE_CYCLE, SWAY_CYCLE, PULSE_CYCLE, BUBBLE_CYCLE, SWIM_CYCLE
]
## After this long, every ambient motion is back where it started.
const AMBIENT_LOOP := 60.0
## Shortest gap between two ambient repaints: about 30 per second.
const AMBIENT_FRAME := 0.033334

# Event steps.

## A token swimming from one cell to another.
const SWIM := 0.9
## One beat of a staged event: a wind-up, a flash, a shake.
const EVENT_STEP := 0.3
## Fog lifting, a defeated monster fading away.
const FADE := 0.6
## Rest between two steps of a story, so each one reads.
const STORY_PAUSE := 0.4

# Curves, as a transition and an easing for Tween.set_trans() and
# set_ease(). Flutter's curves are cubic Béziers fitted to Penner's
# equations, and Godot's are the equations themselves: the same shape,
# off by at most 2.2 % of the move for ENTER, 3.2 % for EXIT, 2.5 % for
# TRAVEL and 4.6 % for POP (TRANS_BACK overshoots by 10 %,
# Curves.easeOutBack by 8.7 %).

## Things arriving, fast then settling: Curves.easeOutCubic.
const ENTER_TRANS := Tween.TRANS_CUBIC
const ENTER_EASE := Tween.EASE_OUT
## Things leaving, slow start then fast end: Curves.easeInCubic.
const EXIT_TRANS := Tween.TRANS_CUBIC
const EXIT_EASE := Tween.EASE_IN
## A move from one place to another: Curves.easeInOutCubic.
const TRAVEL_TRANS := Tween.TRANS_CUBIC
const TRAVEL_EASE := Tween.EASE_IN_OUT
## A small overshoot, for a bounce or a pop: Curves.easeOutBack.
const POP_TRANS := Tween.TRANS_BACK
const POP_EASE := Tween.EASE_OUT


## A token swimming [param cells] cells away: [constant SWIM] for a
## neighbour, longer for a farther cell, never more than three swims.
static func swim_over(cells: float) -> float:
	return SWIM * clampf(sqrt(cells), 1.0, 3.0)


## [param duration], or nothing when the player asked for fewer
## animations: the final state then shows at once.
static func or_instant(duration: float, reduced: bool) -> float:
	return 0.0 if reduced else duration
