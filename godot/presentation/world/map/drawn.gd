class_name Drawn
extends RefCounted
## What a part of the map drew last, told by the values that decide it: the
## model of a level, the size of the map, the cells seen. The map is drawn again
## after each action of the player and each turn, most often with one cell
## changed or none, and a phone drops frames rebuilding what did not change: a
## part asks [method again] before it draws, and keeps what it shows on a yes.

var _values: Array = []


## Whether [param values] (never empty) are the ones drawn last, so that nothing
## is to draw. They are compared exactly, deep through arrays. When they are
## not, they are the ones drawn from now on.
func again(values: Array) -> bool:
	if values == _values:
		return true
	_values = values
	return false
