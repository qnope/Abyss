class_name GuideRaidAlert
extends GuideMessage
## `GuideRaidAlert` of lib/domain/objective/guide/guide_message.dart: the
## first raid, of `monsters` monsters, announced for the end of
## `arrival_turn`: how many Harpoonists stand against it on the base level.

var arrival_turn: int
var monsters: int
## Harpoonists the base level needs to push it back (an int), null when no
## number of them would.
var needed: Variant
## Harpoonists still to recruit, 0 once the base should hold.
var missing: int
## Whether they can be recruited this turn.
var can_recruit: bool
## Whether the raid strikes at the end of this turn.
var last_turn: bool


func _init(
	arrival_turn_: int, monsters_: int, needed_: Variant = null, missing_ := 0,
	can_recruit_ := false, last_turn_ := false,
) -> void:
	arrival_turn = arrival_turn_
	monsters = monsters_
	needed = needed_
	missing = missing_
	can_recruit = can_recruit_
	last_turn = last_turn_


func _figures() -> PackedStringArray:
	return PackedStringArray([
		str(arrival_turn), str(monsters), GuideMessage.or_minus_one(needed), str(missing),
		str(can_recruit), str(last_turn),
	])
