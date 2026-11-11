class_name ProcessResets
extends RefCounted
## The list of every reset of static state, as test/helpers/fresh_process.dart
## lists them for the Flutter tests. Test files share a process, so a class
## with static state (a cache, a registry) exposes
##
##     static func debug_reset() -> void:
##
## and is listed here, as in `return [UnitCatalog.debug_reset]`. The class
## itself knows nothing of the tests (the domain depends on nothing), so the
## test side owns this list.


## The resets TestReset.reset_all() runs before each test file.
static func all() -> Array[Callable]:
	return [
		AssaultRehearsals.debug_reset,
		RaidDefenceAdvisor.debug_reset,
		KernelDefenceAdvisor.debug_reset,
		LeviathanDefenceAdvisor.debug_reset,
		PlanLibrary.debug_reset,
		AppLocale.debug_reset,
	]
