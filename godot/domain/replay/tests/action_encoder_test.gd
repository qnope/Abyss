extends TestCase
## test/domain/replay/action_encoder_test.dart, its groups ActionEncoder and
## SeededRandom. 'writes back a <verb> as the scenario reads it', which Dart
## generates for each action, is one test that loops.

## One action of each verb, as a scenario writes it.
const SCENARIO_ACTIONS: Array[Dictionary] = [
	{"do": "upgrade", "building": "algaeFarm"},
	{"do": "unlock", "branch": "military"},
	{"do": "research", "branch": "explorer"},
	{"do": "research", "branch": "military", "option": "b"},
	{"do": "recruit", "unit": "guardian", "count": 4},
	{"do": "explore", "x": 3, "y": 4},
	{"do": "event", "accept": true},
	{"do": "event", "accept": false},
	{"do": "garrison", "units": {"domeBreaker": 4, "guardian": 2}},
	{"do": "withdraw", "units": {"guardian": 1}},
	{"do": "collect", "x": 3, "y": 4, "level": 2, "seed": 11},
	{"do": "fight", "x": 1, "y": 2, "units": {"harpoonist": 5}, "seed": 12},
	{"do": "attackBase", "x": 1, "y": 2, "units": {"scout": 1}, "seed": 13},
	{"do": "attackKernel", "x": 1, "y": 2, "level": 3, "units": {"abyssAdmiral": 2}, "seed": 14},
	{"do": "attackPlayer", "target": "faction-pirates", "units": {"harpoonist": 5}, "seed": 16},
	{"do": "attackPost", "x": 3, "y": 4, "level": 2, "units": {"harpoonist": 5}, "seed": 18},
	{"do": "attackHeldKernel", "x": 3, "y": 4, "level": 3, "units": {"harpoonist": 5}, "seed": 19},
	{"do": "spy", "target": "faction-pirates"},
	{"do": "spy", "target": "human"},
	{"do": "announceAttack", "units": {"harpoonist": 5}, "seed": 17},
	{"do": "descend", "x": 5, "y": 6, "units": {"guardian": 3}, "seed": 15},
	{"do": "reinforce", "x": 5, "y": 6, "level": 2, "units": {"guardian": 3}},
]


func test_writes_back_every_verb_as_the_scenario_reads_it() -> void:
	for json: Dictionary in SCENARIO_ACTIONS:
		var action: Action = ActionCodec.decode(json).call(DartRandom.new(1, false))

		assert_eq(ActionEncoder.encode(action), json, str(json))
		assert_true(ActionEncoder.is_exact(action), str(json))
		## Not in the Dart file: the keys in the order the scenario writes
		## them, which the journal keeps.
		var encoded: Dictionary = ActionEncoder.encode(action)
		assert_eq(encoded.keys(), json.keys(), str(json))
		if json.has("units"):
			var units: Dictionary = encoded["units"]
			var written: Dictionary = json["units"]
			assert_eq(units.keys(), written.keys(), str(json))


func test_keeps_the_seed_of_a_replayed_fight() -> void:
	var action: FightMonsterAction = ActionCodec.decode({
		"do": "fight", "x": 1, "y": 2, "units": {"harpoonist": 5}, "seed": 7,
	}).call(DartRandom.new(1, false))

	assert_true(action.random.is_seeded)
	assert_eq(action.random.initial_seed, 7)


func test_names_the_human_target_whose_id_changes_between_games() -> void:
	var action := AttackBaseAction.new("uuid-1", {UnitType.Value.GUARDIAN: 2}, DartRandom.new(3))

	var as_human: Dictionary = ActionEncoder.encode(action, "uuid-1")
	var as_other: Dictionary = ActionEncoder.encode(action, "uuid-2")
	assert_eq(as_human["target"], "human")
	assert_eq(as_other["target"], "uuid-1")


func test_leaves_out_units_the_player_did_not_send() -> void:
	var action := DescendAction.new(
		1, 1, 1, {UnitType.Value.SCOUT: 0, UnitType.Value.GUARDIAN: 2}, DartRandom.new(3)
	)

	var move: Dictionary = ActionEncoder.encode(action)
	assert_eq(move["units"], {"guardian": 2})


func test_flags_dice_that_no_seed_can_replay() -> void:
	var action := FightMonsterAction.new(1, 2, 1, {UnitType.Value.HARPOONIST: 1}, DartRandom.new(1, false))

	var move: Dictionary = ActionEncoder.encode(action)
	assert_false(move.has("seed"))
	assert_false(ActionEncoder.is_exact(action))


func test_writes_option_a_of_a_research_as_no_option_at_all() -> void:
	var action := ResearchTechAction.new(TechBranch.Value.RESOURCES, TechOption.Value.A)

	assert_eq(ActionEncoder.encode(action), {"do": "research", "branch": "resources"})


func test_does_not_write_the_end_of_a_turn_as_a_move() -> void:
	assert_null(ActionEncoder.encode(EndTurnAction.new()))


func test_seeded_random_rolls_the_same_dice_as_a_generator_of_the_same_seed() -> void:
	var seeded := DartRandom.new(99)
	var plain := DartRandom.new(99, false)

	assert_eq(
		[seeded.next_int(100), seeded.next_double(), seeded.next_bool()],
		[plain.next_int(100), plain.next_double(), plain.next_bool()],
	)


## Not in the Dart file: every verb that rolls dice, played on the game's
## generator rather than a seed of its own, cannot be replayed.
func test_flags_every_verb_that_rolls_unrecorded_dice() -> void:
	for json: Dictionary in SCENARIO_ACTIONS:
		var unseeded := json.duplicate()
		unseeded.erase("seed")
		var action: Action = ActionCodec.decode(unseeded).call(DartRandom.new(1, false))

		assert_eq(ActionEncoder.is_exact(action), not json.has("seed"), str(json))
		assert_eq(ActionEncoder.encode(action), unseeded, str(json))


## Not in the Dart file: an attack without generator is no seeded one.
func test_an_attack_without_dice_is_not_exact() -> void:
	var assault := AttackBaseAction.new("rival", {UnitType.Value.GUARDIAN: 2})
	var announce := AnnounceAttackAction.new({UnitType.Value.GUARDIAN: 2})

	assert_false(ActionEncoder.is_exact(assault))
	assert_false(ActionEncoder.is_exact(announce))
	assert_eq(ActionEncoder.encode(assault), {"do": "attackPlayer", "target": "rival", "units": {"guardian": 2}})


## Not in the Dart file: Dart switches on the class of the action, so an
## action of another class is no move, whatever its type.
func test_an_action_of_another_class_is_no_move() -> void:
	var other := OtherAction.new()

	assert_null(ActionEncoder.encode(other))
	assert_true(ActionEncoder.is_exact(other))


class OtherAction:
	extends Action

	func type() -> ActionType.Value:
		return ActionType.Value.FIGHT_MONSTER

	func description() -> String:
		return ""

	func validate(_game: Game, _player: Player) -> ActionResult:
		return ActionResult.success()

	func execute(_game: Game, _player: Player) -> ActionResult:
		return ActionResult.success()
