class_name BaseIntel
extends RefCounted
## lib/domain/faction/base_intel.dart: what a scout brought back from the
## base of another player: a snapshot of its headquarters, rampart, army and
## stocks, good for DURATION turns. Past that the base may have changed, and
## the report is only history.

## Turns a report stays fresh once written.
const DURATION := 5

## Turn the scout got back.
var turn: int
var headquarters_level: int
## Level of the Citadel, the rampart of the base; 0 when there is none.
var rampart_level: int
## The units standing on the base level, by type.
var army: Dictionary[UnitType.Value, int]
## What the stocks held, pearls included.
var stocks: Dictionary[ResourceType.Value, int]


func _init(
	turn_: int,
	headquarters_level_: int,
	rampart_level_: int,
	army_: Dictionary[UnitType.Value, int],
	stocks_: Dictionary[ResourceType.Value, int],
) -> void:
	turn = turn_
	headquarters_level = headquarters_level_
	rampart_level = rampart_level_
	army = army_
	stocks = stocks_


## Whether the report still holds on `now`.
func is_fresh(now: int) -> bool:
	return now <= turn + DURATION


## Turns the report has left on `now`, 0 once stale.
func turns_left(now: int) -> int:
	return maxi(0, turn + DURATION - now)
