extends TestCase
## test/domain/script/variant/plan_step_test.dart.

const NONE: Dictionary[UnitType.Value, int] = {}


func test_scales_the_recruits_of_fighters_not_scouts_nor_admirals() -> void:
	var variant := ReplayVariant.new(true, true, 0.8)
	var count_of := func(unit: String) -> Variant:
		var adapted: Dictionary = _step({"do": "recruit", "unit": unit, "count": 10}).adapt(variant, NONE)
		return adapted["count"]

	assert_eq(count_of.call("harpoonist"), 8)
	assert_eq(count_of.call("scout"), 10)
	assert_eq(count_of.call("abyssAdmiral"), 10)


func test_cuts_a_selection_of_units_to_what_is_there() -> void:
	var adapted: Dictionary = _step({
		"do": "descend", "x": 1, "y": 2, "units": {"harpoonist": 70, "scout": 4},
	}).adapt(ReplayVariant.new(), {UnitType.Value.HARPOONIST: 50})

	assert_eq(adapted["units"], {"harpoonist": 50})


func test_gives_up_a_selection_when_none_of_its_units_is_there() -> void:
	var adapted: Variant = _step({
		"do": "attackKernel", "x": 1, "y": 2, "units": {"harpoonist": 70},
	}).adapt(ReplayVariant.new(), NONE)

	assert_null(adapted)


func test_drops_the_dice_of_the_replay_unless_the_variant_keeps_them() -> void:
	var fight := _step({"do": "collect", "seed": 7})
	var descent := _step({"do": "descend", "seed": 7, "units": {"scout": 1}})
	var scouts: Dictionary[UnitType.Value, int] = {UnitType.Value.SCOUT: 1}

	var kept: Dictionary = fight.adapt(ReplayVariant.new(), NONE)
	assert_eq(kept["seed"], 7)
	var other_dice: Dictionary = fight.adapt(ReplayVariant.new(true, false), NONE)
	assert_false(other_dice.has("seed"))
	var descended: Dictionary = descent.adapt(ReplayVariant.new(true, false), scouts)
	assert_eq(descended["seed"], 7)
	var other_map: Dictionary = descent.adapt(ReplayVariant.new(false), scouts)
	assert_false(other_map.has("seed"))


func test_keeps_to_the_steps_on_the_road_to_the_volcano() -> void:
	assert_true(_step({"do": "attackBase"}).persistent())
	assert_true(_step({"do": "descend"}).persistent())
	assert_false(_step({"do": "upgrade"}).persistent())


func test_labels_a_variant_by_what_it_changes() -> void:
	var variant := ReplayVariant.new(false, true, 0.8, 0, 1.0, 6, true)

	assert_false(variant.is_exact())
	assert_true(ReplayVariant.new().is_exact())
	assert_true(variant.label().contains("autre carte"))
	assert_true(variant.label().contains("armée ×0.8"))
	assert_true(variant.label().contains("défense prudente"))


## Not in the Dart file: every part of a label, in its order, and a step's
## level and cell.
func test_labels_every_change_in_order() -> void:
	var variant := ReplayVariant.new(true, false, 2.0, 2, 1.1, 6, true)

	assert_eq(variant.label(), "même carte, autres dés, armée ×2.0, retard 0-2, tempo ×1.1, défense prudente")
	assert_eq(ReplayVariant.new().label(), "même carte, mêmes dés")
	assert_eq(_step({"do": "explore"}).level(), 1)
	assert_eq(_step({"do": "explore", "level": 3, "x": 1}).level(), 3)
	assert_true(_step({"do": "explore", "x": 1}).on_map())
	assert_false(_step({"do": "explore"}).on_map())


## Not in the Dart file: a unit no game knows is never there.
func test_a_unit_no_game_knows_is_never_there() -> void:
	var adapted: Variant = _step({"do": "descend", "units": {"kraken": 3}}).adapt(ReplayVariant.new(), NONE)

	assert_null(adapted)


static func _step(json: Dictionary) -> PlanStep:
	return PlanStep.new(1, 0, json)
