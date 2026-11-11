class_name PlanLibrary
extends RefCounted
## lib/domain/script/variant/plan_library.dart: human plans the raids are
## calibrated on, each played as a few nearby strategies, by the name the
## command line uses.
##
## A plan is an exported replay kept in `scenarios/replays/`, at the root of
## the repository. Dart reads it from the working directory; the domain
## reads no file, so whoever plays the plans (the simulator, the tests)
## hands it a reader first: `use_reader(read)`, `read` giving the text of a
## path of the repository (`scenarios/replays/victoire-tour-85.json`), ""
## when there is none. Add a winning replay there and a line to `PLANS` to
## calibrate on it too.

const FOLDER := "scenarios/replays"
## Plans by short name, with their replay file.
const PLANS: Dictionary[String, String] = {
	"plan85": "victoire-tour-85.json",
	"plan84": "victoire-tour-84.json",
}

static var _read := Callable()


## Sets the reader of the replay files, for every plan built after.
static func use_reader(read: Callable) -> void:
	_read = read


static func debug_reset() -> void:
	_read = Callable()


## What each strategy of a plan changes from it, by the suffix of its name.
## Every one rolls new dice per seed and defends the announced raids, unless
## it says not.
static func variants() -> Dictionary[String, ReplayVariant]:
	return {
		"": ReplayVariant.new(true, false, 1.0, 0, 1.0, 6, true),
		"-newmap": ReplayVariant.new(false, false, 1.0, 0, 1.0, 6, true),
		"-nodefence": ReplayVariant.new(true, false),
		"-army120": ReplayVariant.new(true, false, 1.2, 0, 1.0, 6, true),
		"-army90": ReplayVariant.new(true, false, 0.9, 0, 1.0, 6, true),
		"-late": ReplayVariant.new(true, false, 1.0, 2, 1.0, 6, true),
		"-slow": ReplayVariant.new(true, false, 1.0, 0, 1.1, 6, true),
	}


## The names of the plans and their variants, in Dart's order.
static func names() -> Array[String]:
	var all: Array[String] = []
	for plan: String in PLANS:
		for suffix: String in variants():
			all.append(plan + suffix)
	return all


## The plan of that name, read anew, or null when no plan has that name or
## the reader gives no replay (an error, where Dart throws).
static func by_name(name: String) -> PlanScript:
	for plan: String in PLANS:
		var all := variants()
		for suffix: String in all:
			if plan + suffix == name:
				return _read_plan(plan, all[suffix], name)
	return null


static func _read_plan(plan: String, variant: ReplayVariant, name: String) -> PlanScript:
	var path := FOLDER.path_join(PLANS[plan])
	var source: String = _read.call(path) if _read.is_valid() else ""
	if source.is_empty():
		push_error("PlanLibrary: no replay at %s (use_reader)" % path)
		return null
	return PlanScript.from_replay(source, variant, null, name)
