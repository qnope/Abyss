class_name StrikeEffect
extends MapEffect
## An attack on a cell played on the map (lib/presentation/widgets/map/effects/
## strike/map_strike_run.dart): the army's figures swim to the cell beside what
## they attack and lunge at it once per round; each hit flashes the target white,
## shakes the camera and floats up what each side lost; then on a victory the
## monster rolls over and shrinks into its foot while a place lights up in cyan,
## and on a defeat the army falls back a cell; the army shrinks away at the end.
##
## The monsters of a lair come out of it, a [MonsterFigure] of their family
## (generic when it has none); a place is the content the map already draws,
## flashed through a [HitFlash]. The animations follow [StrikeCues]. It is a thin
## node over the pure classes: [StrikeTimeline], [StrikeGeometry], [FightPace].

## How long a blow shakes the camera, and how far, in metres.
const SHAKE_LENGTH := MapMotion.QUICK
const SHAKE_AMPLITUDE := 0.2
## How long the target flashes after a hit and how white; how much a place taken
## lights up at the middle of the outcome.
const FLASH_LENGTH := MapMotion.TAP
const FLASH_STRENGTH := 0.8
const CAPTURED_GLOW := 0.8
## How small a defeated monster shrinks, how far it rolls over and sinks.
const SHRUNK := 0.3
const ROLL := 1.4
const SINK := 0.25
## How long the monsters take to come out, how far they stand toward the army.
const EMERGE := 0.3
const STAND_OUT := 0.3
## How high over the floor, at least, the losses float up from.
const LOSS_HEIGHT := 1.0

var strike: MapStrike
var geometry: StrikeGeometry
var timeline: StrikeTimeline
var squad: StrikeSquad
## The monsters of the lair, or null when a place is attacked.
var monster: MonsterFigure
var dealt := FloatingNumber.new()
var taken := FloatingNumber.new()
var _cues: Array[StrikeCues]
var _next := 0
var _flash: HitFlash
var _top: float


## The [param strike_] played from where [param geometry_] puts the army, over
## [param content] (what stands on the cell, or null).
func _init(strike_: MapStrike, geometry_: StrikeGeometry, content: Node3D = null) -> void:
	name = &"Strike"
	strike = strike_
	geometry = geometry_
	var approach := geometry.approach()
	var swim := 0.0 if approach == geometry.origin \
		else MapMotion.swim_over(Vector2(approach - geometry.origin).length())
	timeline = StrikeTimeline.new(swim, strike.rounds.size())
	_cues = StrikeCues.of(timeline, strike.rounds)
	squad = StrikeSquad.new(strike.sent)
	add_child(squad)
	var lair := geometry.lair()
	var toward := MapGrid.at(approach.x, approach.y, geometry.width, geometry.height) - lair
	squad.face(-toward)
	_top = LOSS_HEIGHT
	if strike.is_monster():
		monster = MonsterFigure.new(strike.lair.family, strike.lair.difficulty)
		monster.position = lair + toward.normalized() * STAND_OUT
		monster.rotation.y = atan2(toward.x, toward.z) + PI
		add_child(monster)
	elif content != null:
		_top = maxf(ModelBounds.top_of(content), LOSS_HEIGHT)
	var flashed: Node3D = monster if monster != null else content
	if flashed != null:
		_flash = HitFlash.new(flashed)
	add_child(dealt)
	add_child(taken)
	_show(0.0)


func duration() -> float:
	return timeline.total()


func jolt() -> float:
	return MapJolt.offset(timeline.pace().since_last_hit(elapsed), SHAKE_LENGTH, SHAKE_AMPLITUDE)


func _show(t: float) -> void:
	var outcome := timeline.outcome_at(t)
	var gone := MapMotion.exit(timeline.vanish_at(t))
	squad.position = geometry.army_at(timeline.swim_at(t), timeline.reach_at(t), 0.0 if strike.victory else outcome)
	squad.vanish(gone)
	while _next < _cues.size() and _cues[_next].at <= t:
		_play(_cues[_next])
		_next += 1
	_show_losses(t)
	_show_target(t, outcome, gone)


func _play(cue: StrikeCues) -> void:
	var lunge := timeline.pace().lunge()
	var seconds := lunge if cue.animation == &"attack" else 0.0
	if cue.who == StrikeCues.Who.ARMY:
		squad.play(cue.animation, seconds)
	elif monster != null:
		var length := monster.length_of(cue.animation)
		monster.play(cue.animation, length / seconds if seconds > 0.0 and length > 0.0 else 1.0)


## What each side lost in the round showing now: what the army dealt over the
## target, what it took over the army.
func _show_losses(t: float) -> void:
	dealt.visible = false
	taken.visible = false
	var pace := timeline.pace()
	for index in strike.rounds.size():
		if not pace.shows_hit(index, t):
			continue
		var progress := pace.fade_of(index, t)
		if strike.rounds[index].x > 0:
			dealt.show_loss(geometry.lair() + Vector3.UP * _top, strike.rounds[index].x, progress)
		if strike.rounds[index].y > 0:
			taken.show_loss(squad.position + Vector3.UP * LOSS_HEIGHT, strike.rounds[index].y, progress)


## The target flashing as each hit lands; a beaten monster rolls over and shrinks
## to its foot, a place taken lights up in cyan.
func _show_target(t: float, outcome: float, gone: float) -> void:
	var since := timeline.pace().since_last_hit(t)
	var flash := 0.0 if since == FightPace.NONE else FLASH_STRENGTH * (1.0 - since / FLASH_LENGTH)
	if monster != null:
		_show_monster(t, outcome, gone)
	if _flash == null:
		return
	if flash > 0.0:
		_flash.show(MapPalette.FLASH, flash)
	elif strike.victory and monster == null:
		_flash.show(MapPalette.CAPTURE, CAPTURED_GLOW * sin(PI * outcome))
	else:
		_flash.clear()


func _show_monster(t: float, outcome: float, gone: float) -> void:
	var fell := MapMotion.exit(outcome) if strike.victory else 0.0
	var size := MapMotion.enter(MapMotion.share(t, 0.0, EMERGE)) * lerpf(1.0, SHRUNK, fell)
	monster.scale = Vector3.ONE * maxf(size * (1.0 if strike.victory else 1.0 - gone), 0.001)
	monster.rotation.z = ROLL * fell
	monster.position.y = geometry.lair().y - SINK * fell
	monster.visible = outcome < 1.0 or not strike.victory
