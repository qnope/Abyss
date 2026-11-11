extends TestCase
## test/domain/script/strategies/leviathan_guard_test.dart: a player holds
## its Faille against the guardians the turn they strike.

const HOME: Dictionary[UnitType.Value, int] = {
	UnitType.Value.GUARDIAN: 60, UnitType.Value.DOME_BREAKER: 60, UnitType.Value.HARPOONIST: 60,
}
const REPELLED := AttackOutcome.Value.REPELLED


static func _turn_of(war: PostWar) -> ScriptTurn:
	return ScriptTurn.new(war.game, DartRandom.new(5), [])


static func _units_on(war: PostWar, level: int) -> int:
	var sum := 0
	for t: UnitType.Value in UnitType.Value.values():
		sum += war.count(war.human(), level, t)
	return sum


## The scene at the turn the guardians strike, `units` waiting at home.
static func _warned(units: Dictionary[UnitType.Value, int] = HOME) -> PostWar:
	var war := LeviathanScene.of()
	war.put(war.human(), 1, units)
	LeviathanScene.play_until(war, LeviathanScene.strike_turn(war))
	return war


static func _outcome(war: PostWar) -> AttackOutcome.Value:
	return LeviathanScene.end_turn(war).report.outcome()


func test_it_sends_down_part_of_the_home_army_and_holds_the_faille() -> void:
	var war := _warned()
	LeviathanGuardMoves.guard_faille(_turn_of(war))

	assert_true(_units_on(war, 2) > 0)
	assert_true(_units_on(war, 1) > 0)
	assert_eq(_outcome(war), REPELLED)
	assert_eq(war.post.captured_by, war.human().id)


func test_it_does_nothing_before_the_turn_they_strike() -> void:
	var war := LeviathanScene.of()
	war.put(war.human(), 1, HOME)
	LeviathanGuardMoves.guard_faille(_turn_of(war))

	assert_eq(_units_on(war, 2), 0)


func test_units_already_below_that_hold_keep_the_home_army_home() -> void:
	var war := _warned()
	war.put(war.human(), 2, PostWar.WALL)
	LeviathanGuardMoves.guard_faille(_turn_of(war))

	assert_eq(_units_on(war, 1), 180)


func test_with_no_army_at_home_it_recruits_the_guard_it_sends_down() -> void:
	var war := _warned({})
	war.human().buildings[BuildingType.Value.BARRACKS] = Building.new(BuildingType.Value.BARRACKS, 10)
	for r: ResourceType.Value in ResourceType.Value.values():
		war.human().resources[r].amount = 200000
	LeviathanGuardMoves.guard_faille(_turn_of(war))

	assert_true(_units_on(war, 2) > 0)
	assert_eq(_outcome(war), REPELLED)


func test_under_a_raid_it_sends_down_only_what_the_base_can_spare() -> void:
	var war := _warned()
	war.human().raid_state.announce(MonsterLair.new(MonsterDifficulty.Value.EASY, 4), war.game.turn + 1)
	LeviathanGuardMoves.guard_faille(_turn_of(war))

	assert_true(_units_on(war, 2) > 0)
	assert_eq(_outcome(war), REPELLED)


func test_under_a_raid_the_base_needs_only_fresh_recruits_go_down() -> void:
	var war := _warned()
	war.human().raid_state.announce(MonsterLair.new(MonsterDifficulty.Value.HARD, 300), war.game.turn + 1)
	LeviathanGuardMoves.guard_faille(_turn_of(war))

	assert_eq(_units_on(war, 1), 180)


func test_under_a_faction_attack_the_base_needs_the_army_stays_home() -> void:
	var war := _warned()
	war.human().raid_state.attacks.append(
		AnnouncedAttack.new(war.attacker().id, {UnitType.Value.HARPOONIST: 400}, war.game.turn + 1, 1)
	)
	LeviathanGuardMoves.guard_faille(_turn_of(war))

	assert_eq(_units_on(war, 1), 180)


func test_a_hopeless_guard_stays_home() -> void:
	var war := _warned({UnitType.Value.HARPOONIST: 2})
	LeviathanGuardMoves.guard_faille(_turn_of(war))

	assert_eq(_units_on(war, 2), 0)


func test_without_its_module_the_faille_is_left_to_its_fate() -> void:
	var war := _warned()
	war.human().buildings[BuildingType.Value.DESCENT_MODULE] = Building.new(BuildingType.Value.DESCENT_MODULE)
	LeviathanGuardMoves.guard_faille(_turn_of(war))

	assert_eq(_units_on(war, 2), 0)


func test_the_careful_bot_holds_the_faille_it_is_warned_about() -> void:
	var war := _warned()
	ConquestStrategy.new().play_turn(_turn_of(war))

	assert_eq(_outcome(war), REPELLED)
	assert_eq(war.post.captured_by, war.human().id)
