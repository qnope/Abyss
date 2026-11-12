class_name SiegeEffect
extends MapEffect
## A siege played on the map (lib/presentation/widgets/map/effects/story/
## map_siege_run.dart): a red ring pulses twice around the place; the attackers
## close in; at each round of the fight they lunge at it, it flashes, the map
## shakes lightly and what each side lost floats up; then on a victory a cyan
## shield flashes as it pushes them back, on a defeat they break in as the place
## flashes red and the map shakes. A thin node over [SiegeTimeline] and
## [SiegeGeometry].

## How far the camera shakes as the attackers break in, and at each clash, in metres.
const BREACH_SHAKE := 0.3
const CLASH_SHAKE := 0.14
## How long the place flashes after a clash, how bright, and how bright the red
## flash of a breach.
const FLASH_LENGTH := MapMotion.TAP
const FLASH_STRENGTH := 0.4
const BREACH_FLASH := 0.5
## The rings and discs on the floor, as shares of the place's radius.
const ALERT_SCALE := 1.15
const SHIELD_SCALE := 1.1
const SHIELD_FILL := 0.15
## How high over the floor the losses float up from, at least.
const LOSS_HEIGHT := 1.0

var siege: MapSiege
var geometry: SiegeGeometry
var timeline: SiegeTimeline
var attackers: SiegeAttackers
var losses := FightLosses.new()
var _cues: Array[StrikeCues] = []
var _next := 0
var _top := LOSS_HEIGHT
## The marks on the floor around the place: the alert and the shield (rings), the
## shield's fill, the flash of a clash and the red one of a breach (discs).
var alert := FloorMark.new()
var shield := FloorMark.new()
var shield_fill := FloorMark.new(false)
var flash := FloorMark.new(false)
var breach := FloorMark.new(false)


## The [param siege_] played where [param geometry_] puts it, over [param content]
## (what stands on the place, or null).
func _init(siege_: MapSiege, geometry_: SiegeGeometry, content: Node3D = null) -> void:
	name = &"Siege"
	siege = siege_
	geometry = geometry_
	timeline = SiegeTimeline.new(siege.rounds.size())
	attackers = SiegeAttackers.new(siege)
	if content != null:
		_top = maxf(ModelBounds.top_of(content), LOSS_HEIGHT)
	var marks: Array[FloorMark] = [alert, shield, shield_fill, flash, breach]
	for mark in marks:
		mark.position = geometry.center()
		add_child(mark)
	add_child(attackers)
	add_child(losses)
	_cues = _cues_of()
	_show(0.0)


func duration() -> float:
	return timeline.total()


func jolt() -> float:
	if not siege.victory and elapsed >= timeline.impact():
		return MapJolt.offset(elapsed - timeline.impact(), MapMotion.QUICK, BREACH_SHAKE)
	return MapJolt.offset(timeline.clashes().since_last_hit(elapsed), MapMotion.QUICK, CLASH_SHAKE)


## How far the shield has risen at [param t], from 0 to 1; never on a defeat.
func shield_at(t: float) -> float:
	if not siege.victory:
		return 0.0
	return MapMotion.enter(timeline.approach_at(t)) * (1.0 - MapMotion.exit(timeline.outcome_at(t)))


func _show(t: float) -> void:
	var outcome := timeline.outcome_at(t)
	var gone := MapMotion.exit(outcome)
	for index in SiegeGeometry.ATTACKERS:
		attackers.put(index, geometry.attacker_at(index, timeline.approach_at(t),
			timeline.clashes().reach_at(t), outcome if siege.victory else 0.0,
			0.0 if siege.victory else outcome), geometry.center())
	attackers.vanish(gone)
	while _next < _cues.size() and _cues[_next].at <= t:
		attackers.play(_cues[_next].animation, timeline.clashes().lunge() if _cues[_next].animation == &"attack" else 0.0)
		_next += 1
	_show_floor(t, outcome)
	losses.show_at(t, timeline.clashes(), siege.rounds, attackers.where(0) + Vector3.UP * LOSS_HEIGHT,
		geometry.center() + Vector3.UP * _top)


## The cues of the attackers (the army's side of a [StrikeCues]): an attack at
## each clash, then, at the impact, a hit when they are pushed back, or one more
## attack as they break in.
func _cues_of() -> Array[StrikeCues]:
	var cues: Array[StrikeCues] = []
	var pace := timeline.clashes()
	for index in siege.rounds.size():
		cues.append(StrikeCues.new(pace.start + pace.lunge() * index, StrikeCues.Who.ARMY, &"attack"))
	cues.append(StrikeCues.new(timeline.impact(), StrikeCues.Who.ARMY, &"hit" if siege.victory else &"attack"))
	return cues


## The alert, the shield and the flashes on the floor around the place.
func _show_floor(t: float, outcome: float) -> void:
	var radius := geometry.radius()
	alert.show_mark(radius * ALERT_SCALE, MapPalette.ALERT, timeline.alert_at(t))
	var rise := shield_at(t)
	var glow := sin(PI * outcome) if siege.victory else 0.0
	shield_fill.show_mark(radius * SHIELD_SCALE * rise, MapPalette.SHIELD, SHIELD_FILL * rise)
	shield.show_mark(radius * SHIELD_SCALE * rise, MapPalette.SHIELD, minf(1.0, rise * 0.8 + glow))
	var since := timeline.clashes().since_last_hit(t)
	var clash := 0.0 if since == FightPace.NONE else maxf(1.0 - since / FLASH_LENGTH, 0.0)
	flash.show_mark(radius * SHIELD_SCALE, MapPalette.FLASH, FLASH_STRENGTH * clash)
	breach.show_mark(radius * SHIELD_SCALE, MapPalette.DAMAGE, 0.0 if siege.victory else BREACH_FLASH * sin(PI * outcome))
