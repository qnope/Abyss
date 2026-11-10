extends TestCase
## test/domain/action/attack_post/attack_post_outcome_test.dart: who defends
## a post, and what a lost attack leaves.

const HARPOONIST := UnitType.Value.HARPOONIST
const GUARDIAN := UnitType.Value.GUARDIAN
const WALL := PostWar.WALL


func _run(war: PostWar, army: Dictionary[UnitType.Value, int]) -> AttackBaseResult:
	var result: AttackBaseResult = ActionExecutor.new().execute(war.strike(army), war.game, war.attacker())
	return result


func _assaults(player: Player) -> Array[HistoryEntry]:
	return player.history_entries.filter(func(e: HistoryEntry) -> bool: return e is BaseAssaultEntry)


func test_who_defends_the_faille_is_defended_by_the_level_2_units_of_its_owner() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE)
	war.arm(war.attacker(), {HARPOONIST: 12})
	war.put(war.owner(), 2, WALL)
	war.put(war.owner(), 1, {HARPOONIST: 5})
	var result := _run(war, {HARPOONIST: 12})
	assert_eq(result.defence.engaged, WALL)
	assert_false(result.victory)
	assert_eq(war.count(war.owner(), 1, HARPOONIST), 5)


func test_who_defends_the_cheminee_is_defended_by_the_level_3_units_garrison_apart() -> void:
	var war := PostWar.new(TransitionBaseType.Value.CHEMINEE)
	war.arm(war.attacker(), {HARPOONIST: 12})
	war.put(war.owner(), 3, {GUARDIAN: 40})
	war.put(war.owner(), 2, {HARPOONIST: 9})
	war.put(war.owner(), KernelGarrison.STOCK_KEY, {HARPOONIST: 70})
	var result := _run(war, {HARPOONIST: 12})
	assert_eq(result.defence.engaged, {GUARDIAN: 40} as Dictionary[UnitType.Value, int])
	assert_eq(war.count(war.owner(), 4, HARPOONIST), 70)


func test_who_defends_a_post_without_defender_falls_at_once() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE)
	war.arm(war.attacker(), {UnitType.Value.SCOUT: 1})
	var result := _run(war, {UnitType.Value.SCOUT: 1})
	assert_true(result.victory)
	assert_true(result.defence.engaged.is_empty())


func test_a_lost_attack_keeps_the_post_the_passage_and_the_defenders_that_survive() -> void:
	var war := PostWar.new(TransitionBaseType.Value.CHEMINEE)
	war.arm(war.attacker(), {HARPOONIST: 6})
	war.put(war.owner(), 3, WALL)
	var result := _run(war, {HARPOONIST: 6})
	assert_false(result.victory)
	assert_eq(war.post.captured_by, war.owner().id)
	assert_eq(war.owner().buildings[war.passage()].level, 2)
	assert_true(war.count(war.owner(), 3, GUARDIAN) > 0)
	assert_true(war.count(war.attacker(), 2, HARPOONIST) < 6)
	var theirs := _assaults(war.owner())
	assert_eq(theirs.size(), 1)
	var entry: BaseAssaultEntry = theirs[0]
	assert_false(entry.victory)


## Not in the Dart file: a refused attack writes no history and settles
## nothing.
func test_a_refused_attack_leaves_no_trace() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE)
	var action := war.strike(PostWar.HORDE)
	var result := ActionExecutor.new().execute(action, war.game, war.attacker())
	assert_eq(result.reason, ActionFailure.Value.NOT_ENOUGH_UNITS)
	assert_true(result is AttackBaseResult)
	assert_eq(action.execute(war.game, war.attacker()).reason, ActionFailure.Value.NOT_ENOUGH_UNITS)
	assert_true(_assaults(war.attacker()).is_empty())
	assert_true(_assaults(war.owner()).is_empty())
	assert_null(action.make_history_entry(war.game, war.attacker(), ActionResult.success(), 12))
	assert_true(war.attacker().raid_state.post_attack_turns.is_empty())
