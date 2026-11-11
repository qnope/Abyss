extends TestCase
## test/domain/action/held_attack_report/held_post_report_test.dart: the
## attacks on a post the human holds, reported by the end of the turn.

const HARPOONIST := UnitType.Value.HARPOONIST
const FAILLE := TransitionBaseType.Value.FAILLE


## A post of `kind` the human holds, with `below` on the level it opens
## onto, struck by the first faction's `army`.
static func _struck(
	kind: TransitionBaseType.Value,
	below: Dictionary[UnitType.Value, int] = {HARPOONIST: 5},
	army: Dictionary[UnitType.Value, int] = PostWar.HORDE,
	passage := 2,
) -> PostWar:
	var war := PostWar.new(kind, 7, true)
	war.human().buildings[war.passage()].level = passage
	war.arm(war.attacker(), army)
	war.put(war.human(), war.below(), below)
	ActionExecutor.new().execute(war.strike(army), war.game, war.attacker())
	return war


static func _end_turn(war: PostWar) -> TurnResult:
	var result: EndTurnActionResult = EndTurnAction.new(DartRandom.new(1), false).execute(war.game, war.human())
	return result.turn_result


## The single attack the end of the turn reports.
func _single(war: PostWar) -> FactionAttackReport:
	var attacks := _end_turn(war).attacks
	assert_eq(attacks.size(), 1)
	return attacks[0]


func test_a_faille_taken_from_the_human_is_reported_with_its_losses() -> void:
	var war := _struck(FAILLE)

	var report := _single(war)

	assert_eq(report.target(), AttackTarget.Value.POST)
	assert_eq(report.outcome(), AttackOutcome.Value.POST_TAKEN)
	assert_eq(report.attacker_id, war.attacker().id)
	assert_eq(report.attacker_name, war.attacker().name)
	assert_eq(report.personality, war.game.factions()[0].personality)
	assert_eq(report.post().code(), war.post.name)
	assert_eq(report.passage_lost(), BuildingType.Value.DESCENT_MODULE)
	assert_eq(report.units_lost(), 5)
	assert_eq(report.level_below(), 2)
	assert_true(report.entry.defending)


func test_a_cheminee_taken_loses_the_capsule_and_the_third_level() -> void:
	var war := _struck(TransitionBaseType.Value.CHEMINEE, {HARPOONIST: 2, UnitType.Value.SCOUT: 1})

	var report := _single(war)

	assert_eq(report.passage_lost(), BuildingType.Value.PRESSURE_CAPSULE)
	assert_eq(report.units_lost(), 3)
	assert_eq(report.level_below(), 3)


func test_a_post_taken_before_its_passage_was_built_loses_no_passage() -> void:
	var war := _struck(FAILLE, {HARPOONIST: 5}, PostWar.HORDE, 0)

	var report := _single(war)

	assert_eq(report.outcome(), AttackOutcome.Value.POST_TAKEN)
	assert_false(report.entry.passage_destroyed)
	assert_null(report.passage_lost())


func test_a_post_taken_with_nobody_below_loses_no_unit() -> void:
	var war := _struck(FAILLE, {})

	assert_eq(_single(war).units_lost(), 0)


func test_a_post_held_is_a_repelled_attack_that_loses_nothing() -> void:
	var war := _struck(FAILLE, PostWar.WALL, {HARPOONIST: 4})

	var report := _single(war)

	assert_eq(report.target(), AttackTarget.Value.POST)
	assert_eq(report.outcome(), AttackOutcome.Value.REPELLED)
	assert_null(report.passage_lost())
	assert_eq(report.units_lost(), 0)


func test_is_reported_on_the_turn_of_the_attack_only() -> void:
	var war := _struck(FAILLE)
	_end_turn(war)

	assert_true(_end_turn(war).attacks.is_empty())


func test_a_post_the_human_takes_from_a_faction_is_not_reported() -> void:
	var war := PostWar.new(FAILLE)
	war.post.captured_by = war.attacker().id
	war.arm(war.human())
	ActionExecutor.new().execute(war.strike(PostWar.HORDE), war.game, war.human())

	assert_true(_end_turn(war).attacks.is_empty())


func test_an_attacker_no_longer_in_the_game_is_reported_by_its_name() -> void:
	var war := PostWar.new(FAILLE, 7, true)
	war.game.turn = 14
	war.human().add_history_entry(HistorySamples.base_assault_entry(true, true, war.post.name))

	var report := _single(war)

	assert_eq(report.attacker_id, "Nacre")
	assert_eq(report.attacker_name, "Nacre")
	assert_null(report.personality)
