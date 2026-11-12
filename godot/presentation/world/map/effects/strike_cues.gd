class_name StrikeCues
extends RefCounted
## What each side of a strike plays, and when: the order the timeline gives. The
## army swims to the lair and rests there; at the start of each lunge it attacks;
## at the peak of the lunge the monster is hit; if it took something from the army
## in that round, it strikes back a quarter of a lunge later, and the army is hit.
## The cues are sorted by time, so that the playback is a thin node that walks
## the list.

## Who plays the animation.
enum Who { ARMY, MONSTER }

var at: float
var who: Who
var animation: StringName


func _init(at_: float, who_: Who, animation_: StringName) -> void:
	at = at_
	who = who_
	animation = animation_


## The cues of the attack [param timeline] plays the [param rounds] of (what the
## army dealt in x, what it took in y), in order of time.
static func of(timeline: StrikeTimeline, rounds: Array[Vector2i]) -> Array[StrikeCues]:
	var cues: Array[StrikeCues] = []
	if timeline.swim > 0.0:
		cues.append(StrikeCues.new(0.0, Who.ARMY, &"swim"))
	cues.append(StrikeCues.new(timeline.swim, Who.ARMY, &"idle"))
	var pace := timeline.pace()
	for index in rounds.size():
		cues.append(StrikeCues.new(pace.start + pace.lunge() * index, Who.ARMY, &"attack"))
		cues.append(StrikeCues.new(pace.hit_at(index), Who.MONSTER, &"hit"))
		if rounds[index].y > 0:
			var back := pace.hit_at(index) + pace.lunge() / 4.0
			cues.append(StrikeCues.new(back, Who.MONSTER, &"attack"))
			cues.append(StrikeCues.new(back, Who.ARMY, &"hit"))
	return cues
