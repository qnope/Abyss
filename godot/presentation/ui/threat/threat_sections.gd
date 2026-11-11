class_name ThreatSections
extends RefCounted
## The threat sections of the end-of-turn summary, for [SummarySections]: each
## is a list of one section when the turn fought or announced such a threat,
## else empty. They are built here and not by static functions of the nodes
## themselves (a node class that builds itself in a static function leaks its
## script, Godot 4.7).


## The raid fought and the raid announced by [param result].
static func raid(result: TurnResult) -> Array[Control]:
	var found: Array[Control] = []
	if result.raid != null or result.announced_raid != null:
		found.append(RaidTurnSection.new(result))
	return found


## The kraken wave fought and the one announced by [param result].
static func volcano(result: TurnResult) -> Array[Control]:
	var found: Array[Control] = []
	if result.volcano != null or result.announced_wave != null:
		found.append(VolcanoTurnSection.new(result))
	return found
