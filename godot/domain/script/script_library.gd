class_name ScriptLibrary
extends RefCounted
## lib/domain/script/script_library.dart: the built-in strategies, by the
## name a scenario or the command line uses. The human plans of
## `PlanLibrary` (`plan85`...) wait for the module `script/variant`.

const NAMES: Array[String] = ["economy", "balanced", "idle", "conquest", "rush", "tutorial"]


static func names() -> Array[String]:
	return NAMES


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
	push_error("Stratégie inconnue : %s (connues : %s)" % [name, ", ".join(NAMES)])
	return null
