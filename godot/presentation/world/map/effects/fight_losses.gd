class_name FightLosses
extends Node3D
## What each side lost in each round of a fight played on the map, floating up
## over it (StrikeMarks.damage of the Dart map): the number of the round showing
## now, if it cost something. Shared by the strike and the siege.

## What the side that attacks the target dealt over it, and what it took.
var dealt := FloatingNumber.new()
var taken := FloatingNumber.new()


func _init() -> void:
	name = &"Losses"
	add_child(dealt)
	add_child(taken)


## Shows the round of [param pace] that shows at [param t] ([param rounds]: what
## was dealt in x, what was taken in y), the first floating up from
## [param over_dealt] and the second from [param over_taken]; none when no round
## shows.
func show_at(t: float, pace: FightPace, rounds: Array[Vector2i], over_dealt: Vector3, over_taken: Vector3) -> void:
	dealt.visible = false
	taken.visible = false
	for index in rounds.size():
		if not pace.shows_hit(index, t):
			continue
		var progress := pace.fade_of(index, t)
		if rounds[index].x > 0:
			dealt.show_loss(over_dealt, rounds[index].x, progress)
		if rounds[index].y > 0:
			taken.show_loss(over_taken, rounds[index].y, progress)
