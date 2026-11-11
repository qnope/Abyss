extends TestCase
## test/domain/script/variant/plan_library_test.dart.


func before_each() -> void:
	PlanLibrary.use_reader(ReferenceFiles.text_of)


func test_offers_each_human_plan_with_its_variants() -> void:
	var names := ScriptLibrary.names()

	for plan: String in ["plan85", "plan84"]:
		assert_has(names, plan)
		assert_has(names, plan + "-newmap")
		assert_has(names, plan + "-slow")


func test_plays_the_plan84_replay_on_its_own_map() -> void:
	assert_eq(ScriptLibrary.by_name("plan84").map_seed(), 2083200441)


## Not in the Dart file: the plans come in Dart's order, after the built-in
## strategies, each built with its variant.
func test_lists_the_plans_in_dart_order() -> void:
	assert_eq(PlanLibrary.names(), [
		"plan85", "plan85-newmap", "plan85-nodefence", "plan85-army120", "plan85-army90",
		"plan85-late", "plan85-slow", "plan84", "plan84-newmap", "plan84-nodefence",
		"plan84-army120", "plan84-army90", "plan84-late", "plan84-slow",
	] as Array[String])
	var late: PlanScript = ScriptLibrary.by_name("plan85-late")
	assert_eq(late.variant.label(), "même carte, autres dés, retard 0-2, défense prudente")
	assert_null(PlanLibrary.by_name("plan99"))


## Not in the Dart file: the domain reads no file, and says so when no
## reader gives the replay.
func test_a_plan_needs_a_reader_of_its_replay() -> void:
	PlanLibrary.debug_reset()

	expect_error("PlanLibrary: no replay at scenarios/replays/victoire-tour-85.json")
	assert_null(ScriptLibrary.by_name("plan85"))
