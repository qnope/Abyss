class_name SquadState
extends RefCounted
## What the parade shows of one squad: the unit, how many serve, whether the
## barracks is still too low for it (locked: one ghost stands for it), whether
## it can recruit now (the green plus) and the words under its count, which
## `app/` writes in the language on (its name, or the barracks level a locked
## squad waits for: a world scene writes no text of its own).

var type: UnitType.Value
var count: int
var locked: bool
var recruitable: bool
var caption: String


func _init(
	type_: UnitType.Value, count_ := 0, locked_ := false, recruitable_ := false, caption_ := ""
) -> void:
	type = type_
	count = count_
	locked = locked_
	recruitable = recruitable_
	caption = caption_


## How many figures stand: one ghost while locked, else as many as the
## count's tier ([SquadSize]).
func figures() -> int:
	return 1 if locked else SquadSize.of(count)


## Everything the state tells, in a line: two states are the same when their
## signatures are.
func signature() -> String:
	return "%d:%d:%d%d:%s" % [type, count, int(locked), int(recruitable), caption]


## The signature of [param states].
static func signature_of(states: Array[SquadState]) -> String:
	var parts := PackedStringArray()
	for state in states:
		parts.append(state.signature())
	return ",".join(parts)
