class_name Worksite
extends RefCounted
## lib/domain/worksite/worksite.dart: what the player already started this
## turn, building upgrades and research. Emptied when the turn ends.

## Building upgrades done this turn.
var upgrades: int
## Research nodes done this turn.
var research: int


func _init(upgrades_ := 0, research_ := 0) -> void:
	upgrades = upgrades_
	research = research_


## Building sites still free this turn with the headquarters at `hq_level`.
func free_build_sites(hq_level: int) -> int:
	return WorksiteRules.build_sites(hq_level) - upgrades


func can_research() -> bool:
	return research < WorksiteRules.RESEARCH_PER_TURN


func clear() -> void:
	upgrades = 0
	research = 0
