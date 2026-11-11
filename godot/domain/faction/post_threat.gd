class_name PostThreat
extends RefCounted
## lib/domain/faction/post_threat.dart: the largest faction army the human
## knows of near one of its posts, as its scouts last saw it.

var faction: Faction
## Units the report counted on the faction's base.
var units: int
## Turn the scout brought the report back.
var report_turn: int
## Turns since the report, on the turn the threat was read.
var turns_ago: int


func _init(faction_: Faction, units_: int, report_turn_: int, turns_ago_: int) -> void:
	faction = faction_
	units = units_
	report_turn = report_turn_
	turns_ago = turns_ago_
