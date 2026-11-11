class_name ScriptLibrary
extends RefCounted
## lib/domain/script/script_library.dart: the built-in strategies, by the
## name a scenario or the command line uses, with the human plans of
## `PlanLibrary` (`plan85`, `plan85-newmap`...), which need its reader.

const BUILT_IN: Array[String] = ["economy", "balanced", "idle", "conquest", "rush", "tutorial"]


static func names() -> Array[String]:
	var all := BUILT_IN.duplicate()
	all.append_array(PlanLibrary.names())
	return all


## Where Dart throws on an unknown name, logs an error and gives null.
static func by_name(name: String) -> GameScript:
	match name:
		"economy":
			return EconomyStrategy.new()
		"balanced":
			return BalancedStrategy.new()
		"idle":
			return IdleScript.new()
		"conquest":
			return ConquestStrategy.new()
		"rush":
			return ConquestStrategy.new(
				null, 0.5, true, false, true, true, false, false, ConquestStrategy.GROWTH_ORDER, 2,
				ConquestMoves.EXPEDITION_SCOUTS, 2, false, Callable(), false,
				GrowthMoves.RESEARCH_PLAN, GrowthMoves.PICKS, "rush",
			)
		"tutorial":
			return TutorialStrategy.new()
	if PlanLibrary.names().has(name):
		return PlanLibrary.by_name(name)
	push_error("Stratégie inconnue : %s (connues : %s)" % [name, ", ".join(names())])
	return null
