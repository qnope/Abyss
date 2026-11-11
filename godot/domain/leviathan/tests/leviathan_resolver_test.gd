extends TestCase
## test/domain/leviathan/leviathan_resolver_test.dart: the guardians
## announced by the end of the turn before, then fought at the Faille.

const GUARDIAN := UnitType.Value.GUARDIAN
const HARPOONIST := UnitType.Value.HARPOONIST


func test_nothing_is_announced_before_the_turn_it_strikes() -> void:
	var war := LeviathanScene.of()
	assert_eq(LeviathanScene.strike_turn(war), war.game.turn + 3)
	assert_null(LeviathanScene.end_turn(war).announced)
	assert_null(LeviathanResolver.announced_now(war.game))
	assert_null(LeviathanScene.end_turn(war).announced)


func test_the_end_of_the_turn_before_announces_it_for_the_next_one() -> void:
	var war := LeviathanScene.of()
	var strike := LeviathanScene.strike_turn(war)
	LeviathanScene.play_until(war, strike - 1)
	var announced := LeviathanScene.end_turn(war).announced
	assert_eq(war.game.turn, strike)
	assert_eq(announced.turn, strike)
	assert_eq(announced.post_name, war.post.name)
	assert_eq(announced.level, war.level)
	assert_true(announced.at.equals(war.at))
	assert_eq(announced.defending_level(), war.below())
	assert_eq(announced.force(), {
		LeviathanForce.LEVIATHAN_KEY: 1,
		LeviathanForce.SENTINEL_KEY: LeviathanForce.SENTINELS,
	})
	var now := LeviathanResolver.announced_now(war.game)
	assert_true(now.at.equals(war.at))
	assert_eq(now.turn, war.game.turn)


func test_a_strong_level_2_holds_the_faille() -> void:
	var war := LeviathanScene.of()
	var strike := LeviathanScene.strike_turn(war)
	war.put(war.human(), 2, PostWar.WALL)
	LeviathanScene.play_until(war, strike)
	var report := LeviathanScene.end_turn(war).report
	assert_eq(report.outcome(), AttackOutcome.Value.REPELLED)
	assert_eq(report.target(), AttackTarget.Value.POST)
	assert_eq(report.attacker_name, LeviathanForce.ATTACKER_NAME)
	assert_null(report.passage_lost())
	assert_eq(war.post.captured_by, war.human().id)
	assert_eq(war.human().buildings[BuildingType.Value.DESCENT_MODULE].level, 2)
	var entry := report.entry
	assert_true(entry.defending)
	assert_eq(entry.post_name, war.post.name)
	assert_eq(entry.turn, strike)
	assert_eq(entry.units, PostWar.WALL)
	assert_true(war.human().history_entries[-1] == entry)
	var dead := 0
	for n: int in entry.dead.values():
		dead += n
	assert_eq(war.count(war.human(), 2, GUARDIAN) + war.count(war.human(), 2, HARPOONIST), 160 - dead)
	assert_null(LeviathanResolver.announced_now(war.game))
	assert_false(LeviathanScene.leviathan(war).is_scheduled())


func test_an_empty_level_2_loses_the_faille_and_the_module() -> void:
	var war := LeviathanScene.of()
	LeviathanScene.play_until(war, LeviathanScene.strike_turn(war))
	var report := LeviathanScene.end_turn(war).report
	assert_eq(report.outcome(), AttackOutcome.Value.POST_TAKEN)
	assert_eq(report.passage_lost(), BuildingType.Value.DESCENT_MODULE)
	assert_eq(war.human().buildings[BuildingType.Value.DESCENT_MODULE].level, 0)
	assert_null(war.post.captured_by)


func test_a_weak_level_2_is_lost_with_the_faille_and_so_are_the_reinforcements_on_their_way() -> void:
	var war := LeviathanScene.of()
	war.put(war.human(), 2, PostWar.GARRISON)
	var origin := GridPosition.new(0, 0)
	war.human().pending_reinforcements.append_array([
		ReinforcementOrder.new(1, 2, {GUARDIAN: 5}, 11, origin),
		ReinforcementOrder.new(2, 3, {GUARDIAN: 5}, 11, origin),
	])
	LeviathanScene.play_until(war, LeviathanScene.strike_turn(war))
	var report := LeviathanScene.end_turn(war).report
	assert_eq(report.outcome(), AttackOutcome.Value.POST_TAKEN)
	assert_eq(war.count(war.human(), 2, HARPOONIST), 0)
	assert_eq(war.human().pending_reinforcements.size(), 1)
	assert_eq(war.human().pending_reinforcements[0].to_level, 3)
	assert_eq(report.units_lost(), 3)
