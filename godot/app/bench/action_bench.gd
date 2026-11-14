class_name ActionBench
extends Bench
## The bench of what an action of the player costs, on the real game. During
## the run, about twice a second, it plays an action that changes nothing in
## the rules but goes the whole way of a real one ([method GameActions.mark]:
## `acted`, the save, `changed`, the redraw). Every frame is timed as in any
## bench, and for each action the longest of the frames that follow it is
## kept: the summary ends with their average and their worst. The run is over
## once the frames of its last action are in, so that whoever removes the
## game's saves at the end does it after the save of that action.

## The least time between two actions, in seconds.
const EVERY := 0.5
## The frames watched after an action: the save and the redraw may fall on
## the frame after the action's.
const WATCHED := 3

## What each action cost: the longest of the frames that followed it.
var costs := FrameStats.new(INF)
var _actions: GameActions
## When the next action is due, in seconds of the run.
var _next := EVERY
## The frames still to watch for the action played last, and their longest.
var _left := 0
var _longest := 0.0


func _init(actions: GameActions, counter: FrameCounter, seconds: float, subject := "game") -> void:
	super(counter, seconds, subject)
	_actions = actions


## An action is played once the frames of the one before are all in.
func _step(t: float, delta: float) -> void:
	if _left > 0:
		_longest = maxf(_longest, delta)
		_left -= 1
		if _left == 0:
			costs.add(_longest)
	if _left == 0 and t >= _next:
		_next = t + EVERY
		_left = WATCHED
		_longest = 0.0
		_actions.mark(func(_game: Game) -> void: pass)


## An action the end of the run cuts short is left out of the costs, but its
## frames are waited for.
func _finish() -> void:
	_left -= 1
	if _left <= 0:
		super()


func _summary() -> String:
	return "%s · %s" % [super(), FrameReport.action_cost(costs)]
