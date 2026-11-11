extends TestCase
## Not in the Dart files: what HeldAttackReports leaves out beyond the tests
## of held_post_report_test.dart and held_kernel_report_test.dart, an attack
## on the base, a kraken wave, and the human named as the opponent.


func test_a_post_the_human_takes_an_attack_on_the_base_and_a_wave_are_not_reported() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE)
	war.post.captured_by = war.attacker().id
	war.arm(war.human())
	ActionExecutor.new().execute(war.strike(PostWar.HORDE), war.game, war.human())
	var entry := HistorySamples.base_assault_entry(true, true)
	entry.turn = war.game.turn
	war.human().add_history_entry(entry)
	var volcano := HistorySamples.volcano_entry(false)
	volcano.turn = war.game.turn
	war.human().add_history_entry(volcano)
	assert_eq(HeldAttackReports.of(war.game), [])


## The human is never the attacker it reports, even named as the entry's
## opponent.
func test_the_human_is_never_the_attacker() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE, 7, true)
	var entry := HistorySamples.base_assault_entry(true, true, war.post.name)
	entry.turn = war.game.turn
	entry.opponent_name = war.human().name
	war.human().add_history_entry(entry)
	var report := HeldAttackReports.of(war.game)[0]
	assert_eq([report.attacker_id, report.attacker_name], [war.human().name, war.human().name])
