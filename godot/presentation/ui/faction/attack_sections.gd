class_name AttackSections
extends RefCounted
## The section of the end-of-turn summary that tells the attacks of the
## factions, for [SummarySections]: a list of one section when the turn had an
## attack, else empty. Built here and not by a static function of the node
## itself (a node class that builds itself in a static function leaks its
## script, Godot 4.7).


## The attacks on the human that [param result] reports.
static func of(result: TurnResult) -> Array[Control]:
	var found: Array[Control] = []
	if not result.attacks.is_empty():
		found.append(AttackTurnSection.new(result.attacks))
	return found
