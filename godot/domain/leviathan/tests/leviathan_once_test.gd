extends TestCase
## test/domain/leviathan/leviathan_once_test.dart: the guardians strike once,
## and never at a Faille the human lost.


func test_strikes_only_once() -> void:
	var war := LeviathanScene.of()
	LeviathanScene.play_until(war, LeviathanScene.strike_turn(war) + 1)
	for _i: int in 6:
		var outcome := LeviathanScene.end_turn(war)
		assert_null(outcome.report)
		assert_null(outcome.announced)
	var assaults := war.human().history_entries.filter(func(e: HistoryEntry) -> bool: return e is BaseAssaultEntry)
	assert_eq(assaults.size(), 1)


func test_cancelled_when_a_faction_took_the_faille_before_the_warning() -> void:
	var war := LeviathanScene.of()
	LeviathanScene.play_until(war, LeviathanScene.strike_turn(war) - 1)
	war.post.captured_by = war.attacker().id
	assert_null(LeviathanScene.end_turn(war).announced)
	assert_null(LeviathanScene.end_turn(war).report)
	assert_false(LeviathanScene.leviathan(war).is_scheduled())
	assert_eq(war.post.captured_by, war.attacker().id)


func test_cancelled_when_a_faction_took_the_faille_during_the_turn() -> void:
	var war := LeviathanScene.of()
	LeviathanScene.play_until(war, LeviathanScene.strike_turn(war))
	war.post.captured_by = war.attacker().id
	assert_null(LeviathanResolver.announced_now(war.game))
	assert_null(LeviathanScene.end_turn(war).report)
	assert_false(LeviathanScene.leviathan(war).is_scheduled())
	assert_eq(war.post.captured_by, war.attacker().id)


func test_the_same_dice_give_the_same_fight() -> void:
	var play := func() -> Array:
		var war := LeviathanScene.of()
		war.put(war.human(), 2, {UnitType.Value.HARPOONIST: 8})
		LeviathanScene.play_until(war, LeviathanScene.strike_turn(war))
		var report := LeviathanScene.end_turn(war, 11).report
		return [
			report.entry.victory, report.entry.fight_result.turn_count,
			str(report.entry.dead), str(report.entry.wounded),
		]
	assert_eq(play.call(), play.call())


## Not in the Dart file: cancelled, it stays so with the Faille taken back
## before the turn it would have struck.
func test_cancelled_it_stays_so_with_the_faille_taken_back() -> void:
	var war := LeviathanScene.of()
	var strike := LeviathanScene.strike_turn(war)
	LeviathanScene.play_until(war, strike - 1)
	war.post.captured_by = war.attacker().id
	LeviathanScene.end_turn(war)
	war.post.captured_by = war.human().id
	assert_eq(war.game.turn, strike)
	assert_null(LeviathanResolver.announced_now(war.game))
	assert_null(LeviathanScene.end_turn(war).report)
