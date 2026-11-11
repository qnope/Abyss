extends TestCase
## test/domain/script/action_codec_test.dart. Where Dart expects a
## FormatException, decode logs it and returns an invalid Callable.


func test_reads_a_building_upgrade() -> void:
	var action: Action = ActionCodec.decode({"do": "upgrade", "building": "algaeFarm"}).call(_dice())

	assert_true(action is UpgradeBuildingAction)
	var upgrade: UpgradeBuildingAction = action
	assert_eq(upgrade.building_type, BuildingType.Value.ALGAE_FARM)


func test_reads_a_recruitment() -> void:
	var action: RecruitUnitAction = ActionCodec.decode({"do": "recruit", "unit": "guardian", "count": 4}).call(_dice())

	assert_eq(action.unit_type, UnitType.Value.GUARDIAN)
	assert_eq(action.quantity, 4)


func test_hands_the_seeded_generator_to_a_fight() -> void:
	var random := _dice()
	var action: FightMonsterAction = ActionCodec.decode({
		"do": "fight", "x": 3, "y": 4, "units": {"harpoonist": 5},
	}).call(random)

	assert_true(action.random == random)
	assert_eq(action.level, 1)
	assert_eq(action.selected_units, {UnitType.Value.HARPOONIST: 5} as Dictionary[UnitType.Value, int])


func test_reads_the_option_of_a_research() -> void:
	var action: ResearchTechAction = ActionCodec.decode({
		"do": "research", "branch": "explorer", "option": "b",
	}).call(_dice())

	assert_eq(action.branch, TechBranch.Value.EXPLORER)
	assert_eq(action.option, TechOption.Value.B)


func test_a_research_without_option_takes_option_a() -> void:
	var action: ResearchTechAction = ActionCodec.decode({"do": "research", "branch": "military"}).call(_dice())

	assert_eq(action.option, TechOption.Value.A)


func test_rejects_an_unknown_research_option() -> void:
	expect_error("Valeur inconnue : c")
	assert_false(ActionCodec.decode({"do": "research", "branch": "military", "option": "c"}).is_valid())


func test_reads_the_choice_of_an_event() -> void:
	var accepted: ChooseEventAction = ActionCodec.decode({"do": "event", "accept": true}).call(_dice())
	var refused: ChooseEventAction = ActionCodec.decode({"do": "event", "accept": false}).call(_dice())

	assert_true(accepted.accept)
	assert_false(refused.accept)


func test_rejects_the_choice_of_an_event_without_a_boolean() -> void:
	expect_error('Champ booléen "accept" attendu')
	expect_error('Champ booléen "accept" attendu')
	assert_false(ActionCodec.decode({"do": "event"}).is_valid())
	assert_false(ActionCodec.decode({"do": "event", "accept": "yes"}).is_valid())


func test_names_the_field_an_action_is_missing() -> void:
	expect_error('"do"')
	expect_error('"branch"')
	assert_false(ActionCodec.decode({"building": "algaeFarm"}).is_valid())
	assert_false(ActionCodec.decode({"do": "unlock"}).is_valid())


func test_rejects_an_unknown_verb_or_value_right_away() -> void:
	expect_error("Action inconnue : dance")
	expect_error("Valeur inconnue : castle")
	expect_error('Champ entier "y" attendu')
	assert_false(ActionCodec.decode({"do": "dance"}).is_valid())
	assert_false(ActionCodec.decode({"do": "upgrade", "building": "castle"}).is_valid())
	assert_false(ActionCodec.decode({"do": "explore", "x": 1}).is_valid())


## Not in the Dart file: the units of an action, malformed, and the seed of
## its dice, which only a whole number gives.
func test_rejects_units_that_are_not_a_map_of_counts() -> void:
	expect_error('Champ "units" attendu')
	expect_error("Nombre attendu pour guardian")
	expect_error("Valeur inconnue : kraken")
	assert_false(ActionCodec.decode({"do": "garrison", "units": [1]}).is_valid())
	assert_false(ActionCodec.decode({"do": "garrison", "units": {"guardian": "2"}}).is_valid())
	assert_false(ActionCodec.decode({"do": "garrison", "units": {"kraken": 2}}).is_valid())


## Not in the Dart file.
func test_a_seed_that_is_no_whole_number_leaves_the_dice_of_the_game() -> void:
	var random := _dice()
	var json := {"do": "collect", "x": 1, "y": 2, "seed": 3.5}
	var action: CollectTreasureAction = ActionCodec.decode(json).call(random)

	assert_true(action.random == random)
	json["seed"] = 3
	var seeded: CollectTreasureAction = ActionCodec.decode(json).call(random)
	assert_eq([seeded.random.initial_seed, seeded.random.is_seeded], [3, true])


## Not in the Dart file: only the first error is logged, as Dart throws once.
func test_logs_only_the_first_malformed_field() -> void:
	expect_error('Champ entier "x" attendu')
	assert_false(ActionCodec.decode({"do": "explore"}).is_valid())


func _dice() -> DartRandom:
	return DartRandom.new(1, false)
